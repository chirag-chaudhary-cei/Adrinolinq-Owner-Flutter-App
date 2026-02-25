import 'dart:io';

import 'package:adrinolinq_owner/core/network/connectivity_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/manager_team_model.dart';
import '../models/save_team_request.dart';
import '../models/team_player_model.dart';
import '../models/save_team_player_request.dart';

/// Remote data source for Teams API
class TeamsRemoteDataSource {
  TeamsRemoteDataSource({
    required ApiClient apiClient,
    required HiveCacheManager cache,
    required ConnectivityService connectivity,
  })  : _apiClient = apiClient,
        _cache = cache,
        _connectivity = connectivity;

  final ApiClient _apiClient;
  final HiveCacheManager _cache;
  final ConnectivityService _connectivity;

  static const String _cacheKeyTeamsList = 'manager_teams_list';

  /// Get list of teams owned by the current manager
  Future<List<ManagerTeamModel>> getTeamsList() async {
    try {
      print('🔍 [TeamsDS] Fetching manager teams list...');

      final response = await _apiClient.post(
        ApiEndpoints.getTeamsList,
        data: {}, // Empty payload = get current user's teams
      );

      _validateResponse(response, 'Failed to fetch teams list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj == null) {
        print('⚠️ [TeamsDS] No teams data in response');
        await _cache.save(_cacheKeyTeamsList, []);
        return [];
      }

      final List<dynamic> teamsList;
      if (obj is List) {
        teamsList = obj;
      } else if (obj is Map<String, dynamic>) {
        // If single team returned as object
        teamsList = [obj];
      } else {
        print('⚠️ [TeamsDS] Unexpected obj type: ${obj.runtimeType}');
        return [];
      }

      // Filter out deleted teams
      final filteredList = teamsList
          .where((item) => item is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .where((item) => item['deleted'] != true)
          .toList();

      final teams =
          filteredList.map((json) => ManagerTeamModel.fromJson(json)).toList();

      // Cache the teams list
      final cacheData = teams.map((t) => t.toJson()).toList();
      await _cache.save(_cacheKeyTeamsList, cacheData);

      print(
        '💾 [TeamsDS] Cached ${teams.length} teams for manager',
      );

      return teams;
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      if (!_connectivity.isConnected) {
        return _getCachedTeams();
      }

      final cached = _getCachedTeams();
      if (cached.isNotEmpty) return cached;

      throw Exception('Failed to fetch teams list: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error fetching teams: $e');

      final cached = _getCachedTeams();
      if (cached.isNotEmpty) return cached;

      throw Exception('Failed to fetch teams list: $e');
    }
  }

  /// Get cached teams list
  List<ManagerTeamModel> _getCachedTeams() {
    if (!_connectivity.isConnected) {
      print('📴 [TeamsDS] Returning cached teams (offline mode)');
    }
    final cachedData = _cache.get(_cacheKeyTeamsList);
    if (cachedData != null && cachedData is List) {
      return cachedData
          .whereType<Map<String, dynamic>>()
          .map((json) => ManagerTeamModel.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Save or update a team
  Future<int> saveTeam(SaveTeamRequest request) async {
    if (!_connectivity.isConnected) {
      throw Exception(
        'Internet connection required to save team. Please check your connection and try again.',
      );
    }

    // Validate request
    final validationError = request.validate();
    if (validationError != null) {
      throw Exception(validationError);
    }

    try {
      print(
        '💾 [TeamsDS] Saving team: ${request.name} (${request.id != null ? "update" : "create"})',
      );

      final response = await _apiClient.post(
        ApiEndpoints.saveTeams,
        data: request.toJson(),
      );

      _validateResponse(response, 'Failed to save team');

      // Clear cache to force refresh
      await _cache.clear(_cacheKeyTeamsList);

      // Extract team ID from response
      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj is Map<String, dynamic> && obj['id'] != null) {
        final teamId = obj['id'] as int;
        print('✅ [TeamsDS] Team saved with ID: $teamId');
        return teamId;
      } else if (obj is int) {
        print('✅ [TeamsDS] Team saved with ID: $obj');
        return obj;
      } else if (request.id != null) {
        // Update operation, return existing ID
        print('✅ [TeamsDS] Team updated: ${request.id}');
        return request.id!;
      } else if (obj is String && obj.contains('Successfully')) {
        // API returns success message instead of ID for CREATE operations
        print('✅ [TeamsDS] Team created successfully: $obj');
        return 0; // Return 0 as sentinel value since ID isn't provided
      }

      throw Exception('Failed to get team ID from response');
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data['obj'] != null) {
          throw Exception(data['obj'].toString());
        }
      }
      throw Exception('Failed to save team: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error saving team: $e');
      rethrow;
    }
  }

  /// Upload team image
  Future<String> uploadTeamImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last.split('\\').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      AppLogger.info('Uploading team image: $fileName', 'TeamsDataSource');

      final response = await _apiClient.post(
        ApiEndpoints.UploadTeamsFile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to upload image');
      }

      if (response.data is Map<String, dynamic>) {
        final responseCode = response.data['response_code'] as String?;
        if (responseCode == '200' || responseCode == '201') {
          final obj = response.data['obj'] as String?;
          if (obj != null && obj.isNotEmpty) {
            final lastSlashIndex = obj.lastIndexOf('/');
            final extractedFileName =
                lastSlashIndex >= 0 ? obj.substring(lastSlashIndex + 1) : obj;

            if (kDebugMode) {
              print('✅ [TeamsDS] Team image uploaded: $extractedFileName');
            }

            AppLogger.success(
              'Team image uploaded: $extractedFileName',
              'TeamsDataSource',
            );
            return extractedFileName;
          }
        }
        throw Exception(response.data['message'] ?? 'Failed to upload image');
      }

      throw Exception('Invalid response format');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get team image URL
  String getTeamImageUrl(String? imageFile) {
    if (imageFile == null || imageFile.isEmpty) {
      return '';
    }
    return '${_apiClient.baseUrl}${ApiEndpoints.teamUploads}$imageFile';
  }

  /// Get player image URL
  String getPlayerImageUrl(String? imageFile) {
    if (imageFile == null || imageFile.isEmpty) {
      return '';
    }
    return '${_apiClient.baseUrl}${ApiEndpoints.usersUploads}$imageFile';
  }

  /// Get list of players in a team
  Future<List<TeamPlayerModel>> getTeamPlayersList(int teamId) async {
    try {
      print('🔍 [TeamsDS] Fetching team players for team ID: $teamId');

      final response = await _apiClient.post(
        ApiEndpoints.getTeamPlayersList,
        data: {'teamId': teamId},
      );

      _validateResponse(response, 'Failed to fetch team players');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj == null) {
        print('⚠️ [TeamsDS] No players data in response');
        return [];
      }

      final List<dynamic> playersList;
      if (obj is List) {
        playersList = obj;
      } else if (obj is Map<String, dynamic>) {
        playersList = [obj];
      } else {
        print('⚠️ [TeamsDS] Unexpected obj type: ${obj.runtimeType}');
        return [];
      }

      // Filter out deleted players
      final filteredList = playersList
          .where((item) => item is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .where((item) => item['deleted'] != true)
          .toList();

      final players =
          filteredList.map((json) => TeamPlayerModel.fromJson(json)).toList();

      print('✅ [TeamsDS] Fetched ${players.length} players for team $teamId');

      return players;
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      throw Exception('Failed to fetch team players: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error fetching team players: $e');
      throw Exception('Failed to fetch team players: $e');
    }
  }

  /// Add a player to a team
  Future<void> saveTeamPlayers(SaveTeamPlayerRequest player) async {
    try {
      print('📤 [TeamsDS] Saving team player...');

      final response = await _apiClient.post(
        ApiEndpoints.saveTeamPlayers,
        data: player.toJson(),
      );

      _validateResponse(response, 'Failed to save team player');

      print('✅ [TeamsDS] Team player saved successfully');

      AppLogger.success(
        'Saved team player',
        'TeamsDataSource',
      );
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      throw Exception('Failed to save team player: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error saving team player: $e');
      rethrow;
    }
  }

  /// Delete a player from a team
  Future<void> deleteTeamPlayers(int playerId) async {
    try {
      print('🗑️ [TeamsDS] Deleting team player ID: $playerId...');

      final response = await _apiClient.post(
        ApiEndpoints.deleteTeamPlayers,
        data: {'id': playerId},
      );

      _validateResponse(response, 'Failed to delete team player');

      print('✅ [TeamsDS] Team player deleted successfully');

      AppLogger.success(
        'Deleted team player',
        'TeamsDataSource',
      );
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      throw Exception('Failed to delete team player: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error deleting team player: $e');
      rethrow;
    }
  }

  /// Delete a team
  Future<void> deleteTeam(int teamId) async {
    if (!_connectivity.isConnected) {
      throw Exception(
        'Internet connection required to delete team. Please check your connection and try again.',
      );
    }

    try {
      print('🗑️ [TeamsDS] Deleting team ID: $teamId...');

      final response = await _apiClient.post(
        ApiEndpoints.deleteTeams,
        data: {'id': teamId},
      );

      _validateResponse(response, 'Failed to delete team');

      // Clear list cache so next fetch reflects deletion.
      await _cache.clear(_cacheKeyTeamsList);

      print('✅ [TeamsDS] Team deleted successfully');
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      throw Exception('Failed to delete team: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error deleting team: $e');
      rethrow;
    }
  }

  /// Get sport roles list for a specific sport
  Future<List<Map<String, dynamic>>> getSportRolesList(int sportId) async {
    try {
      print('🔍 [TeamsDS] Fetching sport roles for sport ID: $sportId');

      final response = await _apiClient.post(
        ApiEndpoints.getSportRolesList,
        data: {'sportId': sportId},
      );

      _validateResponse(response, 'Failed to fetch sport roles');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj == null) {
        print('⚠️ [TeamsDS] No sport roles data in response');
        return [];
      }

      final List<dynamic> rolesList;
      if (obj is List) {
        rolesList = obj;
      } else if (obj is Map<String, dynamic>) {
        rolesList = [obj];
      } else {
        print('⚠️ [TeamsDS] Unexpected obj type: ${obj.runtimeType}');
        return [];
      }

      final roles = rolesList
          .where((item) => item is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .where((item) => item['deleted'] != true)
          .toList();

      print('✅ [TeamsDS] Fetched ${roles.length} sport roles');

      return roles;
    } on DioException catch (e) {
      print('❌ [TeamsDS] DioException: ${e.message}');
      throw Exception('Failed to fetch sport roles: ${e.message}');
    } catch (e) {
      print('❌ [TeamsDS] Error fetching sport roles: $e');
      throw Exception('Failed to fetch sport roles: $e');
    }
  }

  /// Validate API response
  void _validateResponse(Response response, String errorMessage) {
    if (response.data == null) {
      throw Exception('$errorMessage: No data in response');
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('$errorMessage: Invalid response format');
    }

    final responseCode = data['response_code'] as String?;
    if (responseCode == null) {
      throw Exception('$errorMessage: No response code');
    }

    final obj = data['obj'];

    // Success: response_code is '200', or '201' with non-String obj
    // Error: any other code, or '201' with String obj (validation/server error)
    if (responseCode != '200' && (responseCode != '201' || obj is String)) {
      final message = obj is String ? obj : errorMessage;
      throw Exception(message);
    }
  }
}
