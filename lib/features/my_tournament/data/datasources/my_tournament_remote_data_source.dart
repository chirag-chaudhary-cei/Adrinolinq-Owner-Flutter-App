import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/tournament_registration_model.dart';
import '../models/tournament_team_player_model.dart';
import '../models/my_team_model.dart';

/// My Tournament remote data source - handles API calls for tournament registrations
/// Implements cache-first strategy for offline support
class MyTournamentRemoteDataSource {
  MyTournamentRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;
  HiveCacheManager get _cache => HiveCacheManager.instance;

  static const String _cacheKeyRegistrations = 'my_tournament_registrations';

  static String _cacheKeyTeamPlayers(int teamId) =>
      'my_tournament_team_players_$teamId';

  static String _cacheKeyMyTeam(int tournamentId) =>
      'my_tournament_my_team_$tournamentId';

  void _validateResponse(Response response, String fallbackError) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $fallbackError');
    }

    if (response.data is Map<String, dynamic>) {
      final responseCode = response.data['response_code'] as String?;
      if (responseCode != null && responseCode != '200') {
        final obj = response.data['obj'];
        final errorMessage = obj?.toString() ?? fallbackError;
        throw Exception(errorMessage);
      }
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['obj']?.toString() ?? e.message ?? 'Request failed';
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Please check your internet.';
      default:
        return e.message ?? 'Request failed';
    }
  }

  List<TournamentRegistrationModel>? getCachedRegistrations() {
    final cached = _cache.get(_cacheKeyRegistrations);
    if (cached != null && cached is List) {
      if (kDebugMode) {
        print('📦 [MyTournamentDS] Cache hit: ${cached.length} registrations');
      }
      return cached
          .map(
            (e) =>
                TournamentRegistrationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    return null;
  }

  Future<List<TournamentRegistrationModel>> getTournamentRegistrations() async {
    try {
      if (kDebugMode) {
        print('🔍 [MyTournamentDS] Fetching tournament registrations...');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentRegistrationsList,
        data: {}, // Empty payload = get current user's registrations from token
      );

      _validateResponse(response, 'Failed to load tournament registrations');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj == null) {
        if (kDebugMode) {
          print('⚠️ [MyTournamentDS] No registrations found');
        }
        await _cache.save(_cacheKeyRegistrations, []);
        return [];
      }

      final List<dynamic> registrationsList;
      if (obj is List) {
        registrationsList = obj;
      } else if (obj is Map<String, dynamic> && obj.containsKey('data')) {
        registrationsList = obj['data'] as List<dynamic>;
      } else {
        registrationsList = [obj];
      }

      if (kDebugMode) {
        print(
          '✅ [MyTournamentDS] Registrations fetched: ${registrationsList.length} items',
        );
      }

      final registrations = registrationsList
          .map(
            (e) =>
                TournamentRegistrationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      final cacheData = registrations.map((e) => e.toJson()).toList();
      await _cache.save(_cacheKeyRegistrations, cacheData);
      if (kDebugMode) {
        print('💾 [MyTournamentDS] Registrations cached for offline access');
      }

      return registrations;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] DioException: ${_handleError(e)}');
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        if (kDebugMode) {
          print('📴 [MyTournamentDS] Network error, checking cache...');
        }
        final cached = getCachedRegistrations();
        if (cached != null) {
          if (kDebugMode) {
            print(
              '✅ [MyTournamentDS] Returning cached registrations (offline mode)',
            );
          }
          return cached;
        }
      }

      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] Unexpected error: $e');
      }
      throw Exception('Failed to load tournament registrations: $e');
    }
  }

  Future<void> clearCache() async {
    await _cache.clear(_cacheKeyRegistrations);
    if (kDebugMode) {
      print('🗑️ [MyTournamentDS] Cache cleared');
    }
  }

  List<TournamentTeamPlayerModel>? getCachedTeamPlayers(int teamId) {
    final cached = _cache.get(_cacheKeyTeamPlayers(teamId));
    if (cached != null && cached is List) {
      if (kDebugMode) {
        print(
          '📦 [MyTournamentDS] Cache hit: ${cached.length} team players for teamId: $teamId',
        );
      }
      return cached
          .map(
            (e) =>
                TournamentTeamPlayerModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    return null;
  }

  Future<List<TournamentTeamPlayerModel>> getTournamentTeamPlayers(
    int teamId,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 [MyTournamentDS] Fetching team players for teamId: $teamId');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentTeamPlayersList,
        data: {'teamId': teamId},
      );

      _validateResponse(response, 'Failed to load team players');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj == null) {
        if (kDebugMode) {
          print('⚠️ [MyTournamentDS] No team players found');
        }
        await _cache.save(_cacheKeyTeamPlayers(teamId), []);
        return [];
      }

      final List<dynamic> playersList;
      if (obj is List) {
        playersList = obj;
      } else if (obj is Map<String, dynamic> && obj.containsKey('data')) {
        playersList = obj['data'] as List<dynamic>;
      } else {
        playersList = [obj];
      }

      if (kDebugMode) {
        print(
          '✅ [MyTournamentDS] Team players fetched: ${playersList.length} items',
        );
      }

      final players = playersList
          .map(
            (e) =>
                TournamentTeamPlayerModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      final cacheData = players.map((e) => e.toJson()).toList();
      await _cache.save(_cacheKeyTeamPlayers(teamId), cacheData);
      if (kDebugMode) {
        print(
          '💾 [MyTournamentDS] Team players cached for offline access (teamId: $teamId)',
        );
      }

      return players;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] DioException: ${_handleError(e)}');
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        if (kDebugMode) {
          print('📴 [MyTournamentDS] Network error, checking cache...');
        }
        final cached = getCachedTeamPlayers(teamId);
        if (cached != null) {
          if (kDebugMode) {
            print(
              '✅ [MyTournamentDS] Returning cached team players (offline mode)',
            );
          }
          return cached;
        }
      }

      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] Unexpected error: $e');
      }
      throw Exception('Failed to load team players: $e');
    }
  }

  Future<void> clearTeamPlayersCache(int teamId) async {
    await _cache.clear(_cacheKeyTeamPlayers(teamId));
    if (kDebugMode) {
      print(
        '🗑️ [MyTournamentDS] Team players cache cleared for teamId: $teamId',
      );
    }
  }

  Future<void> saveRegistrationToCache(
    TournamentRegistrationModel registration,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '💾 [MyTournamentDS] Saving registration to cache: tournamentId=${registration.tournamentId}',
        );
      }

      final List<TournamentRegistrationModel> registrations =
          getCachedRegistrations() ?? [];

      final existingIndex = registrations.indexWhere(
        (r) =>
            r.id == registration.id ||
            r.tournamentId == registration.tournamentId,
      );

      if (existingIndex != -1) {
        registrations[existingIndex] = registration;
        if (kDebugMode) {
          print('🔄 [MyTournamentDS] Updated existing registration in cache');
        }
      } else {
        registrations.insert(0, registration);
        if (kDebugMode) {
          print('➕ [MyTournamentDS] Added new registration to cache');
        }
      }

      final cacheData = registrations.map((e) => e.toJson()).toList();
      await _cache.save(_cacheKeyRegistrations, cacheData);

      if (kDebugMode) {
        print(
          '✅ [MyTournamentDS] Cache updated: ${registrations.length} total registrations',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] Failed to save registration to cache: $e');
      }
    }
  }

  String getTournamentImageUrl(String? imageFile) {
    if (imageFile == null || imageFile.isEmpty) {
      return '';
    }
    return '${_apiClient.baseUrl}${ApiEndpoints.tournamentsUploads}$imageFile';
  }

  /// Get cached my team data
  MyTeamModel? getCachedMyTeam(int tournamentId) {
    final cached = _cache.get(_cacheKeyMyTeam(tournamentId));
    if (cached != null && cached is Map) {
      try {
        final map = Map<String, dynamic>.from(cached);
        if (!map.containsKey('id')) return null;
        if (kDebugMode) {
          print(
              '📦 [MyTournamentDS] Cache hit: my team for tournamentId: $tournamentId');
        }
        return MyTeamModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Get my team for a tournament — returns null if no team allocated
  Future<MyTeamModel?> getMyTeam(int tournamentId) async {
    try {
      if (kDebugMode) {
        print(
            '🔍 [MyTournamentDS] Fetching my team for tournamentId: $tournamentId');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getMyTeam,
        data: {'tournamentId': tournamentId},
      );

      final data = response.data as Map<String, dynamic>;
      final responseCode = data['response_code'] as String?;
      final obj = data['obj'];

      if (obj == null ||
          obj is! Map<String, dynamic> ||
          obj.isEmpty ||
          !obj.containsKey('id') ||
          (responseCode != null && responseCode != '200')) {
        if (kDebugMode) {
          print('⚠️ [MyTournamentDS] No team allocated for this tournament');
        }
        await _cache.clear(_cacheKeyMyTeam(tournamentId));
        return null;
      }

      await _cache.save(_cacheKeyMyTeam(tournamentId), obj);
      final team = MyTeamModel.fromJson(obj);
      if (kDebugMode) {
        print(
            '✅ [MyTournamentDS] Team loaded: ${team.name} (${team.teamPlayersList.length} players)');
      }
      return team;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
            '❌ [MyTournamentDS] DioException loading team: ${_handleError(e)}');
      }
      final cached = getCachedMyTeam(tournamentId);
      if (cached != null) return cached;
      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] Unexpected error loading team: $e');
      }
      throw Exception('Failed to load team: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEnrolledPlayers(
    int tournamentId,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🔍 [MyTournamentDS] Fetching enrolled players for tournamentId: $tournamentId',
        );
      }

      final response = await _apiClient.post(
        ApiEndpoints.getUsersList,
        data: {
          'tournamentId': tournamentId,
          'roleId': 4,
        },
      );

      _validateResponse(response, 'Failed to load enrolled players');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj == null) {
        if (kDebugMode) {
          print('⚠️ [MyTournamentDS] No enrolled players found');
        }
        return [];
      }

      if (obj is List) {
        final players = obj.map((e) => e as Map<String, dynamic>).toList();
        if (kDebugMode) {
          print('✅ [MyTournamentDS] Loaded ${players.length} enrolled players');
        }
        return players;
      }

      throw Exception('Invalid response format for enrolled players');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MyTournamentDS] Failed to load enrolled players: $e');
      }
      if (e is DioException) {
        throw Exception(_handleError(e));
      }
      rethrow;
    }
  }
}
