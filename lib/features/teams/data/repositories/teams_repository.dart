import '../datasources/teams_remote_data_source.dart';
import '../models/manager_team_model.dart';
import '../models/save_team_request.dart';

/// Repository for Teams operations
class TeamsRepository {
  TeamsRepository(this._remoteDataSource);

  final TeamsRemoteDataSource _remoteDataSource;

  /// Get list of teams owned by the current manager
  Future<List<ManagerTeamModel>> getTeamsList() async {
    try {
      return await _remoteDataSource.getTeamsList();
    } catch (e) {
      throw Exception(
          'Failed to load teams: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  /// Save or update a team
  Future<int> saveTeam(SaveTeamRequest request) async {
    try {
      return await _remoteDataSource.saveTeam(request);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
