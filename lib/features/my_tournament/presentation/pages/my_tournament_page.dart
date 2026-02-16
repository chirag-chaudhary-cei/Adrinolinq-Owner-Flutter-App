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
import '../../../home/presentation/providers/tournaments_providers.dart';
import '../../../home/data/models/tournament_model.dart';
import '../../data/models/tournament_registration_model.dart';

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

/// Convert TournamentModel to TournamentRegistrationModel
TournamentRegistrationModel _convertToRegistrationModel(
  TournamentModel tournament,
) {
  return TournamentRegistrationModel(
    id: tournament.id,
    creationTimestamp:
        tournament.creationTimestamp ?? DateTime.now().toString(),
    playerUserId: 0, // Not available in simplified API
    tournamentId: tournament.id,
    deleted: false,
    status: true,
    tournamentName: tournament.name,
    tournamentDate: tournament.tournamentDate,
    tournamentEndDate: tournament.tournamentEndDate,
    tournamentImageFile: tournament.imageFile,
    tournamentSportId: tournament.sportId,
    tournamentSport: tournament.sport,
    tournamentFeesAmount: tournament.feesAmount.toDouble(),
    tournamentCountry: tournament.country,
    tournamentState: tournament.state,
    tournamentDistrict: tournament.district,
    tournamentCity: tournament.city,
    tournamentMaxRegistrations: tournament.maximumRegistrationsCount,
    registrationStatus: 'Registered',
    paymentStatus: 'Paid',
  );
}

/// Convert tournament to EventModel for UI
EventModel _convertToEventModel({
  required TournamentModel tournament,
  required String imageUrl,
  required int registeredCount,
}) {
  final locationParts = [
    if (tournament.city != null && tournament.city!.isNotEmpty)
      tournament.city!,
    if (tournament.state != null && tournament.state!.isNotEmpty)
      tournament.state!,
  ];
  final location =
      locationParts.isNotEmpty ? locationParts.join(', ') : 'Location TBA';

  return EventModel(
    id: tournament.id.toString(),
    title: tournament.name ?? 'Tournament',
    category: tournament.sport ?? 'Sport',
    sportId: tournament.sportId,
    location: location,
    date: tournament.tournamentDate != null
        ? _formatDate(tournament.tournamentDate!)
        : 'Date TBA',
    time: tournament.tournamentDate != null
        ? _formatTime(tournament.tournamentDate!)
        : '',
    price: (tournament.feesAmount ?? 0).toStringAsFixed(0),
    imageUrl: imageUrl.isNotEmpty ? imageUrl : 'assets/images/demo1.jpg',
    tags: [tournament.sport ?? 'Sport'],
    registeredCount: registeredCount,
    maxParticipants: tournament.maximumRegistrationsCount ?? 100,
    openOrClose: tournament.openOrClose ?? true,
    inviteCode: tournament.inviteCode,
    registrationStatus: 'Registered',
    paymentStatus: 'Paid',
    community: tournament.community ?? '',
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
    final tournamentsAsync = ref.watch(myTournamentsProvider);

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
              child: tournamentsAsync.when(
                data: (tournaments) {
                  if (tournaments.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accentBlue,
                      onRefresh: () async {
                        ref.invalidate(myTournamentsProvider);
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

                  final filteredTournaments = _searchQuery.isEmpty
                      ? tournaments
                      : tournaments.where((tournament) {
                          final tournamentId = tournament.id.toString();
                          final name = tournament.name ?? '';
                          final searchLower = _searchQuery.toLowerCase();
                          return tournamentId.contains(searchLower) ||
                              name.toLowerCase().contains(searchLower);
                        }).toList();

                  if (filteredTournaments.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accentBlue,
                      onRefresh: () async {
                        ref.invalidate(myTournamentsProvider);
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

                  // Display tournaments directly
                  return RefreshIndicator(
                    color: AppColors.accentBlue,
                    onRefresh: () async {
                      ref.invalidate(myTournamentsProvider);
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
                      itemCount: filteredTournaments.length,
                      itemBuilder: (context, index) {
                        final tournament = filteredTournaments[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: AppResponsive.s(context, 16),
                          ),
                          child: _TournamentCard(
                            tournament: tournament,
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
                    ref.invalidate(myTournamentsProvider);
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
                                    myTournamentsProvider,
                                  );
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

/// Tournament Card Widget - Displays tournament card
class _TournamentCard extends ConsumerWidget {
  const _TournamentCard({
    required this.tournament,
  });

  final TournamentModel tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.read(tournamentsRemoteDataSourceProvider);
    final imageUrl = dataSource.getTournamentImageUrl(tournament.imageFile);

    final enrolledPlayersAsync =
        ref.watch(enrolledPlayersProvider(tournament.id));
    final registeredCount = enrolledPlayersAsync.maybeWhen(
      data: (players) => players.length,
      orElse: () => 0,
    );

    final event = _convertToEventModel(
      tournament: tournament,
      imageUrl: imageUrl,
      registeredCount: registeredCount,
    );

    return EventCard(
      event: event,
      onTap: () => _navigateToDetails(context, event),
      onViewDetails: () => _navigateToDetails(context, event),
    );
  }

  void _navigateToDetails(BuildContext context, EventModel event) {
    final registration = _convertToRegistrationModel(tournament);
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
