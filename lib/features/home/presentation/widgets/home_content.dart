import 'dart:async';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy_provider;

import '../../../../core/routing/app_router.dart';
import '../../../../core/network/connectivity_service.dart';
import '../providers/home_provider.dart';
import '../providers/tournaments_providers.dart';
import '../../data/models/tournament_model.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/user_header.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/event_card.dart';

/// Home screen content widget - uses Riverpod for tournaments API
/// Implements offline-first: shows cached data immediately, refreshes in background
class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key, this.onNavigateToProfile});

  final VoidCallback? onNavigateToProfile;

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent>
    with WidgetsBindingObserver {
  String _searchQuery = '';
  StreamSubscription<bool>? _connectivitySubscription;
  bool _hasShownOfflineDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _connectivitySubscription =
        ConnectivityService.instance.onConnectivityChanged.listen((connected) {
      if (!connected && mounted && !_hasShownOfflineDialog) {
        _hasShownOfflineDialog = true;
        _showNoInternetDialog();
      } else if (connected) {
        _hasShownOfflineDialog = false;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ConnectivityService.instance.isConnected && mounted) {
        _hasShownOfflineDialog = true;
        _showNoInternetDialog();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _reloadProfileIfNeeded();
    }
  }

  Future<void> _reloadProfileIfNeeded() async {
    final provider =
        legacy_provider.Provider.of<HomeProvider>(context, listen: false);
    await provider.reloadProfile();
  }

  void _showNoInternetDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your network connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final isNowConnected =
                      await ConnectivityService.instance.checkConnectivity();
                  if (isNowConnected && mounted) {
                    _hasShownOfflineDialog = false;
                    ref
                        .read(tournamentsNotifierProvider.notifier)
                        .forceRefresh();
                  } else if (mounted) {
                    _hasShownOfflineDialog = true;
                    _showNoInternetDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Dismiss',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  EventModel _tournamentToEvent(TournamentModel tournament) {
    final dataSource = ref.read(tournamentsDataSourceProvider);
    final imageUrl =
        tournament.imageFile != null && tournament.imageFile!.isNotEmpty
            ? dataSource.getTournamentImageUrl(tournament.imageFile)
            : 'assets/images/demo1.jpg';

    String formattedDate = tournament.tournamentDate;
    String formattedTime = '';
    try {
      if (tournament.tournamentDate.isNotEmpty) {
        final parts = tournament.tournamentDate.split(' ');
        if (parts.isNotEmpty) {
          final dateParts = parts[0].split('-');
          if (dateParts.length == 3) {
            final day = dateParts[0];
            final month = dateParts[1];
            final year = dateParts[2];

            final dateTime = DateTime(
              int.parse(year),
              int.parse(month),
              int.parse(day),
              parts.length > 1 ? int.parse(parts[1].split(':')[0]) : 0,
              parts.length > 1 ? int.parse(parts[1].split(':')[1]) : 0,
            );

            final monthNames = [
              'JAN',
              'FEB',
              'MAR',
              'APR',
              'MAY',
              'JUN',
              'JUL',
              'AUG',
              'SEP',
              'OCT',
              'NOV',
              'DEC',
            ];
            formattedDate = '$day-${monthNames[int.parse(month) - 1]}-$year';
            formattedTime = DateFormat('hh:mm a').format(dateTime);
          }
        }
      }
    } catch (_) {}

    return EventModel(
      id: tournament.id.toString(),
      title: _capitalize(tournament.name),
      location:
          '${_capitalize(tournament.city)}, ${_capitalize(tournament.state)}',
      imageUrl: imageUrl,
      date: formattedDate,
      time: formattedTime,
      price: tournament.feesAmount.toStringAsFixed(0),
      category: tournament.sport,
      sportId: tournament.sportId,
      tags: [],
      registeredCount: tournament.currentRegistered,
      maxParticipants: tournament.maximumRegistrationsCount,
      isLive: false,
      openOrClose: tournament.openOrClose,
      inviteCode: tournament.inviteCode,
      community: tournament.community,
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _openTournamentDetails({
    required BuildContext context,
    required EventModel event,
    required TournamentModel tournament,
    required List<TournamentModel>? registeredTournaments,
  }) {
    final hasRegistered = registeredTournaments?.any((t) => t.id == tournament.id) ?? false;

    if (hasRegistered) {
      Navigator.pushNamed(
        context,
        AppRouter.registeredTournamentDetail,
        arguments: {
          'event': event,
          'tournament': tournament,
        },
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.tournamentDetail,
      arguments: tournament,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournamentsAsync = ref.watch(offlineFirstTournamentsProvider);
    final isConnected = ConnectivityService.instance.isConnected;

    return legacy_provider.Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              toolbarHeight: AppResponsive.s(context, 80),
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: UserHeader(
                user: provider.currentUser,
                hasNotifications: true,
                onAvatarTap: () {
                  widget.onNavigateToProfile?.call();
                },
                onNotificationTap: () {},
              ),
            ),
            if (!isConnected)
              SliverToBoxAdapter(
                child: Container(
                  padding: AppResponsive.padding(
                    context,
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.orange.shade100,
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 16,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'re offline. Showing cached data.',
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 12),
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPersistentHeader(
              pinned: false,
              floating: true,
              delegate: _SearchBarDelegate(
                minHeight: AppResponsive.s(context, 70),
                maxHeight: AppResponsive.s(context, 70),
                child: Container(
                  color: Colors.white,
                  padding: AppResponsive.padding(
                    context,
                    horizontal: 20,
                    top: 10,
                    bottom: 10,
                  ),
                  child: AppSearchBar(
                    hintText: 'Search Destination',
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
          body: RefreshIndicator(
            color: AppColors.accentBlue,
            displacement: AppResponsive.s(context, 80),
            onRefresh: () async {
              await ref
                  .read(tournamentsNotifierProvider.notifier)
                  .forceRefresh();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                tournamentsAsync.when(
                  data: (tournaments) {
                    final filteredTournaments = _searchQuery.isEmpty
                        ? tournaments
                        : tournaments
                            .where(
                              (t) =>
                                  t.name.toLowerCase().contains(_searchQuery) ||
                                  t.sport
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  t.city.toLowerCase().contains(_searchQuery),
                            )
                            .toList();

                    if (filteredTournaments.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding:
                                AppResponsive.padding(context, vertical: 60),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sports_tennis,
                                  size: AppResponsive.icon(context, 64),
                                  color: Colors.grey.shade400,
                                ),
                                AppResponsive.verticalSpace(context, 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No tournaments available'
                                      : 'No tournaments found',
                                  style: TextStyle(
                                    fontSize: AppResponsive.font(context, 16),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (!isConnected) ...[
                                  AppResponsive.verticalSpace(context, 8),
                                  Text(
                                    'Pull down to refresh when online',
                                    style: TextStyle(
                                      fontSize: AppResponsive.font(context, 12),
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final myTournamentsAsync = ref.watch(myTournamentsProvider);

                    return SliverPadding(
                      padding: AppResponsive.paddingSymmetric(
                        context,
                        horizontal: 20,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tournament = filteredTournaments[index];
                            final event = _tournamentToEvent(tournament);

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: AppResponsive.s(context, 16),
                              ),
                              child: EventCard(
                                event: event,
                                onTap: () {
                                  _openTournamentDetails(
                                    context: context,
                                    event: event,
                                    tournament: tournament,
                                    registeredTournaments: myTournamentsAsync.value,
                                  );
                                },
                                onViewDetails: () {
                                  _openTournamentDetails(
                                    context: context,
                                    event: event,
                                    tournament: tournament,
                                    registeredTournaments: myTournamentsAsync.value,
                                  );
                                },
                              ),
                            );
                          },
                          childCount: filteredTournaments.length,
                        ),
                      ),
                    );
                  },
                  loading: () => SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppLoading.center(message: "Loading tournaments..."),
                  ),
                  error: (error, stack) => SliverToBoxAdapter(
                    child: ErrorView(
                      message: error.toString(),
                      onRetry: () {
                        ref.invalidate(offlineFirstTournamentsProvider);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppResponsive.verticalSpace(context, 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  _SearchBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final currentHeight = (maxExtent - shrinkOffset).clamp(0.0, maxExtent);
    if (currentHeight < 1) return const SizedBox.shrink();
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
