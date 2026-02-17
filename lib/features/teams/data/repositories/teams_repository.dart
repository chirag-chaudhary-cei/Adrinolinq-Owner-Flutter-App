import 'dart:io';

import '../datasources/teams_remote_data_source.dart';
import '../models/manager_team_model.dart';
import '../models/save_team_request.dart';
import '../models/team_player_model.dart';
import '../models/save_team_player_request.dart';

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

  /// Upload team image
  Future<String> uploadTeamImage(File imageFile) async {
    return await _remoteDataSource.uploadTeamImage(imageFile);
  }

  /// Get team image URL
  String getTeamImageUrl(String? imageFile) {
    return _remoteDataSource.getTeamImageUrl(imageFile);
  }

  /// Get player image URL
  String getPlayerImageUrl(String? imageFile) {
    return _remoteDataSource.getPlayerImageUrl(imageFile);
  }

  /// Get list of players in a team
  Future<List<TeamPlayerModel>> getTeamPlayersList(int teamId) async {
    try {
      return await _remoteDataSource.getTeamPlayersList(teamId);
    } catch (e) {
      throw Exception(
          'Failed to load team players: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  /// Add a player to a team
  Future<void> saveTeamPlayers(SaveTeamPlayerRequest player) async {
    try {
      return await _remoteDataSource.saveTeamPlayers(player);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Delete a player from a team
  Future<void> deleteTeamPlayers(int playerId) async {
    try {
      return await _remoteDataSource.deleteTeamPlayers(playerId);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get sport roles list for a specific sport
  Future<List<Map<String, dynamic>>> getSportRolesList(int sportId) async {
    try {
      return await _remoteDataSource.getSportRolesList(sportId);
    } catch (e) {
      throw Exception(
          'Failed to load sport roles: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}
