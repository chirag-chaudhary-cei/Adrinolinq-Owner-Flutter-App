import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/datasources/teams_remote_data_source.dart';
import '../../data/models/manager_team_model.dart';
import '../../data/models/team_player_model.dart';
import '../../data/repositories/teams_repository.dart';

/// Provider for TeamsRemoteDataSource
final teamsRemoteDataSourceProvider = Provider<TeamsRemoteDataSource>((ref) {
  return TeamsRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    cache: ref.read(hiveCacheManagerProvider),
    connectivity: ref.read(connectivityServiceProvider),
  );
});

/// Provider for TeamsRepository
final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  return TeamsRepository(ref.read(teamsRemoteDataSourceProvider));
});

/// Provider for teams list
final teamsListProvider = FutureProvider<List<ManagerTeamModel>>((ref) async {
  final repository = ref.read(teamsRepositoryProvider);
  return repository.getTeamsList();
});

/// Provider for team players list
final teamPlayersProvider = FutureProvider.family<List<TeamPlayerModel>, int>(
  (ref, teamId) async {
    final repository = ref.read(teamsRepositoryProvider);
    return repository.getTeamPlayersList(teamId);
  },
);

/// Provider for sport roles list
final sportRolesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
  (ref, sportId) async {
    final repository = ref.read(teamsRepositoryProvider);
    return repository.getSportRolesList(sportId);
  },
);
