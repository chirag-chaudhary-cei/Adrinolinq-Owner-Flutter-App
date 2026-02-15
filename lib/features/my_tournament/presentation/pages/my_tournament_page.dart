import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/global_app_bar.dart' hide AppSearchBar;
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/my_tournament_providers.dart';
import '../../data/models/tournament_registration_model.dart';
import '../../../home/presentation/providers/tournaments_providers.dart';

/// Parse date from API format (DD-MM-YYYY HH:MM:SS)
DateTime? _parseApiDate(String dateStr) {
  if (dateStr.isEmpty) return null;
  try {
    final normalized = dateStr.replaceAll('/', '-');
    return DateFormat('dd-MM-yyyy HH:mm:ss').parse(normalized);
  } catch (_) {
    try {
      return DateTime.tryParse(dateStr);
    } catch (_) {
      return null;
    }
  }
}

/// Format date as 'DD MMM YYYY'
String _formatDate(String dateStr) {
  final date = _parseApiDate(dateStr);
  if (date == null) return dateStr;
  return DateFormat('dd MMM yyyy').format(date);
}

/// Format time as 'hh:mm AM/PM'
String _formatTime(String dateStr) {
  final date = _parseApiDate(dateStr);
  if (date == null) return '';
  return DateFormat('hh:mm a').format(date);
}

/// Convert registration + tournament to EventModel for UI
EventModel _convertToEventModel({
  required TournamentRegistrationModel registration,
  required String imageUrl,
  String? tournamentName,
  String? tournamentSport,
  int? tournamentSportId,
  String? tournamentDate,
  String? city,
  String? state,
  double? feesAmount,
  int? maxRegistrations,
  int? registeredCount,
  bool? openOrClose,
  String? inviteCode,
  String? community,
}) {
  final locationParts = [
    if (city != null && city.isNotEmpty) city,
    if (state != null && state.isNotEmpty) state,
  ];
  final location =
      locationParts.isNotEmpty ? locationParts.join(', ') : 'Location TBA';

  return EventModel(
    id: registration.tournamentId.toString(),
    title: tournamentName ?? registration.tournamentName ?? 'Tournament',
    category: tournamentSport ?? registration.tournamentSport ?? 'Sport',
    sportId: tournamentSportId ?? registration.tournamentSportId,
    location: location,
    date: tournamentDate != null
        ? _formatDate(tournamentDate)
        : _formatDate(registration.creationTimestamp),
    time: tournamentDate != null
        ? _formatTime(tournamentDate)
        : _formatTime(registration.creationTimestamp),
    price: (feesAmount ?? registration.tournamentFeesAmount ?? 0)
        .toStringAsFixed(0),
    imageUrl: imageUrl.isNotEmpty ? imageUrl : 'assets/images/demo1.jpg',
    tags: [tournamentSport ?? registration.tournamentSport ?? 'Sport'],
    registeredCount: registeredCount ?? 0,
    maxParticipants:
        (maxRegistrations ?? registration.tournamentMaxRegistrations ?? 100),
    openOrClose: openOrClose ?? true,
    inviteCode: inviteCode ?? registration.inviteCode,
    registrationStatus: registration.registrationStatus ?? 'Registered',
    paymentStatus: registration.paymentStatusId == 1
        ? 'Paid'
        : (registration.paymentStatus ?? 'Pending'),
    community: community ?? '',
  );
}

/// My Tournament Page - View registered tournaments and events
class MyTournamentPage extends ConsumerStatefulWidget {
  const MyTournamentPage({super.key});

  @override
  ConsumerState<MyTournamentPage> createState() => _MyTournamentPageState();
}

class _MyTournamentPageState extends ConsumerState<MyTournamentPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final registrationsAsync = ref.watch(myTournamentRegistrationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GlobalAppBar(
              title: 'My Tournaments',
              subtitle: 'Your registered tournaments',
            ),
            SizedBox(height: AppResponsive.s(context, 16)),
            Padding(
              padding: AppResponsive.padding(context, horizontal: 20),
              child: AppSearchBar(
                hintText: 'Search Tournaments',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: AppResponsive.s(context, 16)),
            Expanded(
              child: registrationsAsync.when(
                data: (registrations) {
                  if (registrations.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accentBlue,
                      onRefresh: () async {
                        ref.invalidate(myTournamentRegistrationsProvider);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: AppResponsive.s(context, 64),
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: AppResponsive.s(context, 16)),
                                Text(
                                  'No Registered Tournaments',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: AppResponsive.s(context, 8)),
                                Text(
                                  'Register for tournaments to see them here',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 14),
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: AppResponsive.s(context, 8)),
                                Text(
                                  'Pull down to refresh',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 12),
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final filteredRegistrations = _searchQuery.isEmpty
                      ? registrations
                      : registrations.where((reg) {
                          final tournamentId = reg.tournamentId.toString();
                          final name = reg.tournamentName ?? '';
                          final searchLower = _searchQuery.toLowerCase();
                          return tournamentId.contains(searchLower) ||
                              name.toLowerCase().contains(searchLower);
                        }).toList();

                  if (filteredRegistrations.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accentBlue,
                      onRefresh: () async {
                        ref.invalidate(myTournamentRegistrationsProvider);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: AppResponsive.s(context, 64),
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: AppResponsive.s(context, 16)),
                                Text(
                                  'No Results Found',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: AppResponsive.s(context, 8)),
                                Text(
                                  'Pull down to refresh',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 12),
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accentBlue,
                    onRefresh: () async {
                      ref.invalidate(myTournamentRegistrationsProvider);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: AppResponsive.padding(
                        context,
                        horizontal: 20,
                        bottom: 20,
                      ),
                      itemCount: filteredRegistrations.length,
                      itemBuilder: (context, index) {
                        final registration = filteredRegistrations[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: AppResponsive.s(context, 16),
                          ),
                          child: _TournamentCard(
                            registration: registration,
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => Center(
                  child: AppLoading.circular(
                    color: AppColors.accentBlue,
                  ),
                ),
                error: (error, stack) => RefreshIndicator(
                  color: AppColors.accentBlue,
                  onRefresh: () async {
                    ref.invalidate(myTournamentRegistrationsProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Padding(
                          padding: AppResponsive.padding(context, all: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: AppResponsive.s(context, 64),
                                color: Colors.red.shade300,
                              ),
                              SizedBox(height: AppResponsive.s(context, 16)),
                              Text(
                                'Failed to load tournaments',
                                style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  fontSize: AppResponsive.font(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: AppResponsive.s(context, 8)),
                              Text(
                                error.toString().replaceAll('Exception: ', ''),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  fontSize: AppResponsive.font(context, 14),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: AppResponsive.s(context, 16)),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref.invalidate(
                                      myTournamentRegistrationsProvider,);
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentBlue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppResponsive.s(context, 24),
                                    vertical: AppResponsive.s(context, 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tournament Card Widget - Fetches tournament details for proper display
class _TournamentCard extends ConsumerWidget {
  const _TournamentCard({required this.registration});

  final TournamentRegistrationModel registration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync =
        ref.watch(tournamentByIdProvider(registration.tournamentId));

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) {
          return _buildBasicCard(context, ref);
        }

        final dataSource = ref.read(myTournamentRemoteDataSourceProvider);
        final imageUrl = dataSource.getTournamentImageUrl(tournament.imageFile);

        final enrolledPlayersAsync =
            ref.watch(enrolledPlayersProvider(registration.tournamentId));
        final registeredCount = enrolledPlayersAsync.maybeWhen(
          data: (players) => players.length,
          orElse: () => 0,
        );

        final event = _convertToEventModel(
          registration: registration,
          imageUrl: imageUrl,
          tournamentName: tournament.name,
          tournamentSport: tournament.sport,
          tournamentSportId: tournament.sportId,
          tournamentDate: tournament.tournamentDate,
          city: tournament.city,
          state: tournament.state,
          feesAmount: tournament.feesAmount,
          maxRegistrations: tournament.maximumRegistrationsCount,
          registeredCount: registeredCount,
          openOrClose: tournament.openOrClose,
          inviteCode: tournament.inviteCode,
          community: tournament.community,
        );

        return EventCard(
          event: event,
          onTap: () => _navigateToDetails(context, event),
          onViewDetails: () => _navigateToDetails(context, event),
        );
      },
      loading: () => _buildLoadingCard(context, ref),
      error: (_, __) => _buildBasicCard(context, ref),
    );
  }

  Widget _buildBasicCard(BuildContext context, WidgetRef ref) {
    final dataSource = ref.read(myTournamentRemoteDataSourceProvider);
    final imageUrl = dataSource.getTournamentImageUrl(null);

    final event = _convertToEventModel(
      registration: registration,
      imageUrl: imageUrl,
      tournamentSportId: registration.tournamentSportId,
      openOrClose: registration.inviteCode != null ? false : true,
      inviteCode: registration.inviteCode,
    );

    return EventCard(
      event: event,
      onTap: () => _navigateToDetails(context, event),
      onViewDetails: () => _navigateToDetails(context, event),
    );
  }

  Widget _buildLoadingCard(BuildContext context, WidgetRef ref) {
    return Container(
      height: AppResponsive.s(context, 350),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: AppResponsive.borderRadius(context, 33),
      ),
      child: Center(
        child: AppLoading.circular(color: AppColors.accentBlue),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, EventModel event) {
    Navigator.pushNamed(
      context,
      AppRouter.registeredTournamentDetail,
      arguments: {
        'event': event,
        'registration': registration,
      },
    );
  }
}
