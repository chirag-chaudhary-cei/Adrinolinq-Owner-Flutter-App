import 'package:adrinolinq_owner/core/network/connectivity_service.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/manager_team_model.dart';
import '../models/save_team_request.dart';

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
