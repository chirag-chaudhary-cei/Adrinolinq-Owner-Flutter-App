import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/repositories/matches_repository.dart';
import '../../data/repositories/teams_repository.dart';
import '../../data/models/match_model.dart';
import '../../data/models/enriched_match_model.dart';

/// Matches repository provider
final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MatchesRepository(apiClient);
});

/// Matches list provider - fetches matches for a specific tournament or all matches
final matchesListProvider =
    FutureProvider.family<List<MatchModel>, int?>((ref, tournamentId) async {
  final repository = ref.read(matchesRepositoryProvider);
  return repository.getTournamentRoundMatchesList(tournamentId);
});

/// Enriched matches list provider - fetches matches with team names
///
/// This provider optimizes API calls by:
/// 1. Fetching all matches first
/// 2. Batch fetching all group teams in parallel
/// 3. Batch fetching all team details in parallel
/// 4. Combining everything into enriched match models
final enrichedMatchesListProvider =
    FutureProvider.family<List<EnrichedMatchModel>, int?>(
        (ref, tournamentId) async {
  // Step 1: Fetch all matches
  final matchesRepository = ref.read(matchesRepositoryProvider);
  final matches =
      await matchesRepository.getTournamentRoundMatchesList(tournamentId);

  if (matches.isEmpty) {
    return [];
  }

  // Step 2: Extract unique group IDs and batch fetch group teams
  final teamsRepository = ref.read(teamsRepositoryProvider);
  final uniqueGroupIds =
      matches.map((match) => match.tournamentRoundGroupId).toSet().toList();

  final groupTeamsMap =
      await teamsRepository.batchGetGroupTeams(uniqueGroupIds);

  // Step 3: Extract all unique team IDs and batch fetch team details
  final allTeamIds = <int>{};
  for (final groupTeams in groupTeamsMap.values) {
    for (final groupTeam in groupTeams) {
      allTeamIds.add(groupTeam.tournamentTeamId);
    }
  }

  final teamDetailsMap =
      await teamsRepository.batchGetTeamDetails(allTeamIds.toList());

  // Step 4: Combine everything into enriched matches
  final enrichedMatches = <EnrichedMatchModel>[];

  for (final match in matches) {
    final groupTeams = groupTeamsMap[match.tournamentRoundGroupId] ?? [];

    String team1Name = 'Team 1';
    String team2Name = 'Team 2';

    if (groupTeams.isNotEmpty) {
      final team1 = teamDetailsMap[groupTeams[0].tournamentTeamId];
      team1Name = team1?.teamName ?? 'Team 1';
    }

    if (groupTeams.length > 1) {
      final team2 = teamDetailsMap[groupTeams[1].tournamentTeamId];
      team2Name = team2?.teamName ?? 'Team 2';
    }

    enrichedMatches.add(
      EnrichedMatchModel(
        match: match,
        team1Name: team1Name,
        team2Name: team2Name,
      ),
    );
  }

  return enrichedMatches;
});
