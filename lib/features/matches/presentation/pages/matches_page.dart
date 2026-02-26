import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../home/presentation/providers/tournaments_providers.dart';
import '../providers/matches_providers.dart';
import '../widgets/tournament_dropdown.dart';

class MatchesPage extends ConsumerStatefulWidget {
  const MatchesPage({super.key});

  @override
  ConsumerState<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<MatchesPage> {
  int? selectedTournamentId;

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateString);
      return DateFormat("d MMM yyyy").format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String dateString) {
    try {
      final parsedDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateString);
      return DateFormat("h:mm a").format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournamentsAsync = ref.watch(tournamentsNotifierProvider);
    final matchesAsync =
        ref.watch(enrichedMatchesListProvider(selectedTournamentId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const GlobalAppBar(
              title: 'Matches',
              subtitleColor: AppColors.accentBlue,
            ),
            Divider(height: 1, color: Colors.grey[200]),

            // Filters
            Padding(
              padding: EdgeInsets.only(
                top: AppResponsive.s(context, 16),
                left: AppResponsive.s(context, 16),
                right: AppResponsive.s(context, 16),
              ),
              child: tournamentsAsync.when(
                data: (tournaments) {
                  return TournamentDropdown(
                    label: 'Tournament',
                    hint: 'Select Tournament Name',
                    value: selectedTournamentId,
                    tournaments: tournaments,
                    icon: Icons.apartment_outlined,
                    onChanged: (val) {
                      setState(() {
                        selectedTournamentId = val;
                      });
                    },
                  );
                },
                loading: () => TournamentDropdown(
                  label: 'Tournament',
                  hint: 'Loading...',
                  value: null,
                  tournaments: const [],
                  icon: Icons.apartment_outlined,
                  isLoading: true,
                  onChanged: (val) {},
                ),
                error: (_, __) => TournamentDropdown(
                  label: 'Tournament',
                  hint: 'Error loading tournaments',
                  value: null,
                  tournaments: const [],
                  icon: Icons.apartment_outlined,
                  enabled: false,
                  onChanged: (val) {},
                ),
              ),
            ),

            // Match List
            Expanded(
              child: matchesAsync.when(
                data: (matches) {
                  if (matches.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accentBlue,
                      onRefresh: () async {
                        ref.invalidate(
                          enrichedMatchesListProvider(selectedTournamentId),
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sports_soccer,
                                  size: AppResponsive.icon(context, 64),
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: AppResponsive.s(context, 16)),
                                Text(
                                  'No matches found',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 16),
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: AppResponsive.s(context, 8)),
                                Text(
                                  'Pull down to refresh',
                                  style: TextStyle(
                                    fontFamily: 'SFProRounded',
                                    fontSize: AppResponsive.font(context, 12),
                                    color: Colors.grey[500],
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
                      ref.invalidate(
                        enrichedMatchesListProvider(selectedTournamentId),
                      );
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: AppResponsive.padding(context, bottom: 20),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final enrichedMatch = matches[index];
                        return MatchCardNew.fromMatchStatus(
                          matchStatusId: enrichedMatch.match.matchStatusId,
                          team1Name: enrichedMatch.team1Name,
                          team1Section: '',
                          team2Name: enrichedMatch.team2Name,
                          team2Section: '',
                          headerLabel:
                              "Round - ${enrichedMatch.tournamentRoundId}",
                          team1Score: 0,
                          team2Score: 0,
                          matchDate: enrichedMatch.matchDatetime.isNotEmpty
                              ? _formatDate(enrichedMatch.matchDatetime)
                              : null,
                          matchTime: enrichedMatch.matchDatetime.isNotEmpty
                              ? _formatTime(enrichedMatch.matchDatetime)
                              : null,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentBlue,
                  ),
                ),
                error: (error, stack) => RefreshIndicator(
                  color: AppColors.accentBlue,
                  onRefresh: () async {
                    ref.invalidate(
                      enrichedMatchesListProvider(selectedTournamentId),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: AppResponsive.icon(context, 64),
                              color: Colors.red[400],
                            ),
                            SizedBox(height: AppResponsive.s(context, 16)),
                            Text(
                              'Error loading matches',
                              style: TextStyle(
                                fontFamily: 'SFProRounded',
                                fontSize: AppResponsive.font(context, 16),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 8)),
                            Padding(
                              padding: AppResponsive.padding(
                                context,
                                horizontal: 32,
                              ),
                              child: Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SFProRounded',
                                  fontSize: AppResponsive.font(context, 12),
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            SizedBox(height: AppResponsive.s(context, 16)),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.invalidate(
                                  enrichedMatchesListProvider(
                                    selectedTournamentId,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppResponsive.s(context, 24),
                                  vertical: AppResponsive.s(context, 12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
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
