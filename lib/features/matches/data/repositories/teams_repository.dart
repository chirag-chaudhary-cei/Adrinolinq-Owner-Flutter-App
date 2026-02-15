import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/providers/app_providers.dart';
import '../models/tournament_round_group_team_model.dart';
import '../models/tournament_team_model.dart';

class TeamsRepository {
  final ApiClient _apiClient;

  TeamsRepository(this._apiClient);

  /// Fetches teams for a specific tournament round group
  Future<List<TournamentRoundGroupTeamModel>> getTournamentRoundGroupTeamsList(
    int tournamentRoundGroupId,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getTournamentRoundGroupTeamsList,
        data: {
          'tournamentRoundGroupId': tournamentRoundGroupId,
        },
      );

      if (response.statusCode == 200 &&
          response.data['response_code'] == '200') {
        final List<dynamic> data = response.data['obj'] ?? [];
        final teams = data
            .map(
              (json) => TournamentRoundGroupTeamModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();
        return teams;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Fetches details for a specific tournament team
  Future<TournamentTeamModel?> getTournamentTeam(int tournamentTeamId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getTournamentTeamsList,
        data: {
          'id': tournamentTeamId,
        },
      );

      if (response.statusCode == 200 &&
          response.data['response_code'] == '200') {
        final List<dynamic> data = response.data['obj'] ?? [];
        if (data.isNotEmpty) {
          final team =
              TournamentTeamModel.fromJson(data.first as Map<String, dynamic>);
          return team;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Batch fetches multiple group teams in parallel for optimization
  Future<Map<int, List<TournamentRoundGroupTeamModel>>> batchGetGroupTeams(
    List<int> groupIds,
  ) async {
    final results = await Future.wait(
      groupIds.map((groupId) => getTournamentRoundGroupTeamsList(groupId)),
    );

    final Map<int, List<TournamentRoundGroupTeamModel>> groupTeamsMap = {};
    for (int i = 0; i < groupIds.length; i++) {
      groupTeamsMap[groupIds[i]] = results[i];
    }
    return groupTeamsMap;
  }

  /// Batch fetches multiple tournament teams in parallel for optimization
  Future<Map<int, TournamentTeamModel?>> batchGetTeamDetails(
    List<int> teamIds,
  ) async {
    final results = await Future.wait(
      teamIds.map((teamId) => getTournamentTeam(teamId)),
    );

    final Map<int, TournamentTeamModel?> teamsMap = {};
    for (int i = 0; i < teamIds.length; i++) {
      teamsMap[teamIds[i]] = results[i];
    }
    return teamsMap;
  }
}

// Provider for the teams repository
final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TeamsRepository(apiClient);
});
