import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/connectivity_service.dart';
import '../models/tournament_model.dart';
import '../models/team_model.dart';
import '../models/team_player_model.dart';
import '../../../teams/data/models/manager_team_model.dart';

/// Tournaments remote data source - handles all API calls for tournaments
/// Implements offline-first caching strategy with Hive
class TournamentsRemoteDataSource {
  TournamentsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;
  HiveCacheManager get _cache => HiveCacheManager.instance;
  ConnectivityService get _connectivity => ConnectivityService.instance;

  /// Get base URL for image URLs
  String get baseUrl => _apiClient.baseUrl;

  /// Handle Dio errors
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

  /// Validate API response - checks both HTTP status code and response_code
  void _validateResponse(Response response, String fallbackError) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $fallbackError');
    }

    if (response.data is Map<String, dynamic>) {
      final responseCode = response.data['response_code'] as String?;
      final obj = response.data['obj'];

      if (responseCode != '200' && (responseCode != '201' || obj is String)) {
        final errorMessage = response.data['message'] as String? ??
            (obj is String ? obj : null) ??
            fallbackError;
        throw Exception(errorMessage);
      }
    }
  }

  /// Get tournaments list with offline-first caching
  Future<List<TournamentModel>> getTournamentsList() async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching tournaments list...');
      }

      final payload = {
        'status': true,
        'deleted': false,
        'enrollmentType': 1,
      };

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentsList,
        data: payload,
      );

      _validateResponse(response, 'Failed to fetch tournaments list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        if (kDebugMode) {
          print(
            '⚠️ [TournamentsDS] No tournaments from API - preserving cache',
          );
        }
        final cached = _getCachedTournaments();
        if (cached.isNotEmpty) {
          if (kDebugMode) {
            print(
              '✅ [TournamentsDS] Returning ${cached.length} cached tournaments',
            );
          }
          return cached;
        }
        return [];
      }

      final filtered = obj.where((item) {
        final itemMap = item as Map<String, dynamic>;
        final status = itemMap['status'] as bool? ?? false;
        final deleted = itemMap['deleted'] as bool? ?? false;
        return status && !deleted;
      }).toList();

      final tournaments = filtered
          .map((item) => TournamentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final cacheData = tournaments.map((t) => t.toJson()).toList();
      await _cache.saveTournamentsList(cacheData);
      if (kDebugMode) {
        print('💾 [TournamentsDS] Cached ${tournaments.length} tournaments');
      }

      return tournaments;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] DioException: ${_handleError(e)}');
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _getCachedTournaments();
      }
      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Error: $e');
      }
      final cached = _getCachedTournaments();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw Exception('Failed to fetch tournaments list: $e');
    }
  }

  List<TournamentModel> _getCachedTournaments() {
    if (kDebugMode) {
      print('📴 [TournamentsDS] Returning cached tournaments (offline mode)');
    }
    final cachedData = _cache.getTournamentsList();
    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData.map((e) => TournamentModel.fromJson(e)).toList();
    }
    return [];
  }

  List<TournamentModel>? getCachedTournamentsList() {
    final cachedData = _cache.getTournamentsList();
    if (cachedData != null) {
      return cachedData.map((e) => TournamentModel.fromJson(e)).toList();
    }
    return null;
  }

  bool hasCachedTournaments() {
    return _cache.hasTournamentsList();
  }

  /// Get my tournaments list (tournaments I'm registered for) with offline-first caching
  Future<List<TournamentModel>> getMyTournamentsList() async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching my tournaments list...');
      }

      final payload = {
        'status': true,
        'deleted': false,
        'enrollmentType': 1,
        'myTournaments': true,
      };

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentsList,
        data: payload,
      );

      _validateResponse(response, 'Failed to fetch my tournaments list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [TournamentsDS] No registered tournaments found');
        }
        return [];
      }

      final filtered = obj.where((item) {
        final itemMap = item as Map<String, dynamic>;
        final status = itemMap['status'] as bool? ?? false;
        final deleted = itemMap['deleted'] as bool? ?? false;
        return status && !deleted;
      }).toList();

      final tournaments = filtered
          .map((item) => TournamentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        print(
            '✅ [TournamentsDS] Found ${tournaments.length} registered tournaments');
      }

      return tournaments;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] DioException: ${_handleError(e)}');
      }
      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Error: $e');
      }
      throw Exception('Failed to fetch my tournaments list: $e');
    }
  }

  Future<TournamentModel?> getTournamentById(int tournamentId) async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching tournament by ID: $tournamentId');
      }

      final cachedList = _cache.getTournamentsList();
      if (cachedList != null && cachedList.isNotEmpty) {
        final cachedTournament = cachedList.firstWhere(
          (t) => t['id'] == tournamentId,
          orElse: () => <String, dynamic>{},
        );
        if (cachedTournament.isNotEmpty) {
          if (kDebugMode) {
            print('📦 [TournamentsDS] Cache hit: tournament $tournamentId');
          }
          return TournamentModel.fromJson(cachedTournament);
        }
      }

      final payload = {
        'id': tournamentId,
        'status': true,
        'deleted': false,
        'enrollmentType': 1,
      };

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentsList,
        data: payload,
      );

      _validateResponse(response, 'Failed to fetch tournament');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [TournamentsDS] Tournament $tournamentId not found');
        }
        return null;
      }

      final tournament =
          TournamentModel.fromJson(obj.first as Map<String, dynamic>);

      await _cache.saveTournamentDetail(tournamentId, tournament.toJson());
      if (kDebugMode) {
        print(
          '💾 [TournamentsDS] Cached tournament detail: ${tournament.name}',
        );
      }

      return tournament;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
          '❌ [TournamentsDS] DioException fetching tournament: ${_handleError(e)}',
        );
      }

      final cachedDetail = _cache.getTournamentDetail(tournamentId);
      if (cachedDetail != null) {
        if (kDebugMode) {
          print(
            '📴 [TournamentsDS] Returning cached tournament detail (offline mode)',
          );
        }
        return TournamentModel.fromJson(cachedDetail);
      }

      final cachedList = _cache.getTournamentsList();
      if (cachedList != null) {
        final cachedTournament = cachedList.firstWhere(
          (t) => t['id'] == tournamentId,
          orElse: () => <String, dynamic>{},
        );
        if (cachedTournament.isNotEmpty) {
          return TournamentModel.fromJson(cachedTournament);
        }
      }

      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Error fetching tournament: $e');
      }
      throw Exception('Failed to fetch tournament: $e');
    }
  }

  TournamentModel? getCachedTournamentById(int tournamentId) {
    final cachedDetail = _cache.getTournamentDetail(tournamentId);
    if (cachedDetail != null) {
      return TournamentModel.fromJson(cachedDetail);
    }

    final cachedList = _cache.getTournamentsList();
    if (cachedList != null) {
      final cachedTournament = cachedList.firstWhere(
        (t) => t['id'] == tournamentId,
        orElse: () => <String, dynamic>{},
      );
      if (cachedTournament.isNotEmpty) {
        return TournamentModel.fromJson(cachedTournament);
      }
    }
    return null;
  }

  Future<List<TeamModel>> getTeamsList(int tournamentId) async {
    try {
      if (kDebugMode) {
        print(
          '🔍 [TournamentsDS] Fetching teams for tournament: $tournamentId',
        );
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTeamsList,
        data: {},
      );

      _validateResponse(response, 'Failed to fetch teams list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        return [];
      }

      final filteredObj = obj.where((item) {
        final itemMap = item as Map<String, dynamic>;
        final deleted = itemMap['deleted'] as bool? ?? false;
        return !deleted;
      }).toList();

      final teams = filteredObj
          .map((item) => TeamModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final cacheData = teams.map((t) => t.toJson()).toList();
      await _cache.saveTeamsList(tournamentId, cacheData);
      if (kDebugMode) {
        print(
          '💾 [TournamentsDS] Cached ${teams.length} teams for tournament $tournamentId',
        );
      }

      return teams;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] DioException: ${_handleError(e)}');
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _getCachedTeams(tournamentId);
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cached = _getCachedTeams(tournamentId);
      if (cached.isNotEmpty) {
        return cached;
      }
      throw Exception('Failed to fetch teams list: $e');
    }
  }

  List<TeamModel> _getCachedTeams(int tournamentId) {
    if (kDebugMode) {
      print('📴 [TournamentsDS] Returning cached teams (offline mode)');
    }
    final cachedData = _cache.getTeamsList(tournamentId);
    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData.map((e) => TeamModel.fromJson(e)).toList();
    }
    return [];
  }

  List<TeamModel>? getCachedTeamsList(int tournamentId) {
    final cachedData = _cache.getTeamsList(tournamentId);
    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData.map((e) => TeamModel.fromJson(e)).toList();
    }
    return null;
  }

  /// Get manager teams list - returns all teams owned by the logged-in manager
  Future<List<ManagerTeamModel>> getManagerTeamsList() async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching manager teams...');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTeamsList,
        data: {},
      );

      _validateResponse(response, 'Failed to fetch manager teams list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [TournamentsDS] No manager teams found');
        }
        return [];
      }

      final filteredObj = obj.where((item) {
        final itemMap = item as Map<String, dynamic>;
        final deleted = itemMap['deleted'] as bool? ?? false;
        final status = itemMap['status'] as bool? ?? true;
        return !deleted && status;
      }).toList();

      final teams = filteredObj
          .map(
              (item) => ManagerTeamModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        print('✅ [TournamentsDS] Fetched ${teams.length} manager teams');
      }

      return teams;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] DioException: ${_handleError(e)}');
      }
      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Error: $e');
      }
      throw Exception('Failed to fetch manager teams list: $e');
    }
  }

  Future<List<TeamPlayerModel>> getTeamPlayersList(int teamId) async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching players for team: $teamId');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTeamPlayersList,
        data: {'teamId': teamId},
      );

      _validateResponse(response, 'Failed to fetch team players list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        return [];
      }

      final players = obj
          .map((item) => TeamPlayerModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final cacheData = players.map((p) => p.toJson()).toList();
      await _cache.saveTeamPlayersList(teamId, cacheData);
      if (kDebugMode) {
        print(
          '💾 [TournamentsDS] Cached ${players.length} players for team $teamId',
        );
      }

      return players;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] DioException: ${_handleError(e)}');
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _getCachedTeamPlayers(teamId);
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cached = _getCachedTeamPlayers(teamId);
      if (cached.isNotEmpty) {
        return cached;
      }
      throw Exception('Failed to fetch team players list: $e');
    }
  }

  List<TeamPlayerModel> _getCachedTeamPlayers(int teamId) {
    if (kDebugMode) {
      print('📴 [TournamentsDS] Returning cached team players (offline mode)');
    }
    final cachedData = _cache.getTeamPlayersList(teamId);
    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData.map((e) => TeamPlayerModel.fromJson(e)).toList();
    }
    return [];
  }

  List<TeamPlayerModel>? getCachedTeamPlayersList(int teamId) {
    final cachedData = _cache.getTeamPlayersList(teamId);
    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData.map((e) => TeamPlayerModel.fromJson(e)).toList();
    }
    return null;
  }

  Future<dynamic> saveTeam({
    required int tournamentId,
    required String teamName,
    int? teamId,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception(
        'Internet connection required to save team. Please check your connection and try again.',
      );
    }

    try {
      final payload = {
        'tournamentId': tournamentId,
        'name': teamName,
        if (teamId != null) 'id': teamId,
      };

      final response = await _apiClient.post(
        ApiEndpoints.saveTeams,
        data: payload,
      );

      _validateResponse(response, 'Failed to save team');

      await _cache.clear('teams_$tournamentId');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['obj'];
      }

      return null;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to save team: $e');
    }
  }

  Future<dynamic> saveTeamPlayer({
    required int teamId,
    required int playerId,
    int? id,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception(
        'Internet connection required to add team player. Please check your connection and try again.',
      );
    }

    try {
      final payload = {
        'teamId': teamId,
        'playerId': playerId,
        if (id != null) 'id': id,
      };

      final response = await _apiClient.post(
        ApiEndpoints.saveTeamPlayers,
        data: payload,
      );

      _validateResponse(response, 'Failed to save team player');

      await _cache.clear('team_players_$teamId');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['obj'];
      }

      return null;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to save team player: $e');
    }
  }

  String getTournamentImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return '';
    }
    return '$baseUrl${ApiEndpoints.tournamentsUploads}$fileName';
  }

  Future<Map<String, dynamic>?> getTournamentRegistrationStatus(
    int tournamentId,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🔍 [TournamentsDS] Checking registration status for tournament: $tournamentId',
        );
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentRegistrationsList,
        data: {'tournamentId': tournamentId},
      );

      _validateResponse(response, 'Failed to check registration status');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj is List && obj.isNotEmpty) {
        return obj.first as Map<String, dynamic>;
      } else if (obj is Map<String, dynamic>) {
        return obj;
      }

      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
          '❌ [TournamentsDS] Registration status error: ${_handleError(e)}',
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Registration status error: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSportRolesList(int sportId) async {
    try {
      final cacheKey = 'sport_roles_$sportId';
      final cached = _cache.get(cacheKey);
      if (cached != null && cached is List) {
        if (kDebugMode) {
          print(
            '⚡ [TournamentsDS] Returning cached sport roles for sport $sportId',
          );
        }
        return List<Map<String, dynamic>>.from(cached);
      }

      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching sport roles for sport: $sportId');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getSportRolesList,
        data: {'sportId': sportId},
      );

      _validateResponse(response, 'Failed to fetch sport roles');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        return [];
      }

      final roles = obj
          .where((item) {
            final itemMap = item as Map<String, dynamic>;
            final status = itemMap['status'] as bool? ?? true;
            final deleted = itemMap['deleted'] as bool? ?? false;
            return status && !deleted;
          })
          .map((item) => item as Map<String, dynamic>)
          .toList();

      await _cache.save(cacheKey, roles);
      if (kDebugMode) {
        print('💾 [TournamentsDS] Cached ${roles.length} sport roles');
      }

      return roles;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Sport roles error: ${_handleError(e)}');
      }
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to fetch sport roles: $e');
    }
  }

  Future<Map<String, dynamic>?> saveTournamentTeam({
    required int tournamentId,
    required String name,
    int? captainUserId,
    int? id,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception('Internet connection required to save team.');
    }

    try {
      final payload = {
        'tournamentId': tournamentId,
        'name': name,
        if (captainUserId != null) 'captainUserId': captainUserId,
        if (id != null && id > 0) 'id': id,
      };

      if (kDebugMode) {
        print('💾 [TournamentsDS] Saving tournament team: $payload');
      }

      final response = await _apiClient.post(
        ApiEndpoints.saveTournamentTeams,
        data: payload,
      );

      _validateResponse(response, 'Failed to save team');

      await _cache.clear('teams_$tournamentId');

      if (kDebugMode) {
        print('📨 [TournamentsDS] Save Team Response: ${response.data}');
      }

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final obj = data['obj'];
        if (obj is Map<String, dynamic>) {
          if (kDebugMode) {
            print('✅ [TournamentsDS] Team created with ID: ${obj['id']}');
          }
          return obj;
        } else if (obj is String) {
          if (obj.toLowerCase().contains('successfully')) {
            if (kDebugMode) {
              print(
                '⚠️ [TournamentsDS] Team saved but no ID. Fetching teams to find ID...',
              );
            }
            try {
              final teams = await getTeamsList(tournamentId);
              final createdTeam = teams.firstWhere(
                (t) => t.name.toLowerCase() == name.toLowerCase(),
                orElse: () =>
                    throw Exception("Team created but not found in list"),
              );

              if (kDebugMode) {
                print(
                  '✅ [TournamentsDS] Found created team ID: ${createdTeam.id}',
                );
              }

              return createdTeam.toJson();
            } catch (e) {
              print(
                '❌ [TournamentsDS] Failed to retrieve team ID after creation: $e',
              );
              throw Exception(
                "Team created successfully. Please refresh to see it.",
              );
            }
          }

          if (kDebugMode) print('⚠️ [TournamentsDS] Error from server: $obj');
          throw Exception(obj);
        } else {
          if (kDebugMode) print('⚠️ [TournamentsDS] obj is not a Map: $obj');
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      throw Exception('Failed to save team: $e');
    }
  }

  Future<Map<String, dynamic>?> saveTournamentTeamPlayer({
    required int teamId,
    required int playerUserId,
    int? tournamentId,
    int? sportRoleId,
    int? id,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception('Internet connection required to add player.');
    }

    try {
      final payload = {
        'teamId': teamId,
        'playerUserId': playerUserId,
        if (tournamentId != null) 'tournamentId': tournamentId,
        if (sportRoleId != null) 'sportRoleId': sportRoleId,
        if (id != null && id > 0) 'id': id,
      };

      if (kDebugMode) {
        print('💾 [TournamentsDS] Saving team player: $payload');
      }

      final response = await _apiClient.post(
        ApiEndpoints.saveTournamentTeamPlayers,
        data: payload,
      );

      _validateResponse(response, 'Failed to add player');

      await _cache.clear('team_players_$teamId');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final obj = data['obj'];
        if (obj is Map<String, dynamic>) {
          return obj;
        } else if (obj is String) {
          if (obj.toLowerCase().contains('successfully')) {
            if (kDebugMode) {
              print(
                '✅ [TournamentsDS] Player added successfully (Message: $obj)',
              );
            }
            return {'status': 'success', 'message': obj};
          }
          if (obj.contains('Violation of UNIQUE KEY') ||
              obj.contains('duplicate key')) {
            throw Exception("Player is already added to this team.");
          }
          throw Exception(obj);
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to add player: $e');
    }
  }

  Future<Map<String, dynamic>?> saveTournamentRegistrations({
    required int teamId,
    required int tournamentId,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception('Internet connection required to register.');
    }

    try {
      final payload = {
        'teamId': teamId,
        'tournamentId': tournamentId,
      };

      if (kDebugMode) {
        print('💾 [TournamentsDS] Saving tournament registration: $payload');
      }

      final response = await _apiClient.post(
        ApiEndpoints.saveTournamentRegistrations,
        data: payload,
      );

      _validateResponse(response, 'Failed to register team');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final obj = data['obj'];

        if (kDebugMode) {
          print('✅ [TournamentsDS] Registration successful: $obj');
        }

        if (obj is Map<String, dynamic>) {
          return obj;
        } else if (obj is String) {
          if (obj.contains('Violation of UNIQUE KEY') ||
              obj.contains('duplicate key')) {
            throw Exception("Team is already registered for this tournament.");
          }
          return {'status': 'success', 'message': obj};
        }
      }

      return {'status': 'success', 'message': 'Registration completed'};
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to register team: $e');
    }
  }

  Future<Map<String, dynamic>?> saveTournamentRegistrationWithInviteCode({
    required int tournamentId,
    required int teamId,
    required String inviteCode,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception('Internet connection required to register.');
    }

    try {
      final payload = {
        'tournamentId': tournamentId,
        'teamId': teamId,
        'inviteCode': inviteCode,
      };

      if (kDebugMode) {
        print(
          '💾 [TournamentsDS] Saving tournament registration with invite code: $payload',
        );
      }

      final response = await _apiClient.post(
        ApiEndpoints.saveTournamentRegistrations,
        data: payload,
      );

      _validateResponse(response, 'Failed to register for tournament');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final obj = data['obj'];

        if (kDebugMode) {
          print('✅ [TournamentsDS] Invite registration successful: $obj');
        }

        if (obj is Map<String, dynamic>) {
          return obj;
        } else if (obj is String) {
          return {'status': 'success', 'message': obj};
        }
      }

      return {'status': 'success', 'message': 'Registration completed'};
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to register: $e');
    }
  }

  Future<bool> saveTournamentTeamPlayersBulk({
    required int teamId,
    required List<Map<String, dynamic>> players,
  }) async {
    if (!_connectivity.isConnected) {
      throw Exception('Internet connection required to add players.');
    }

    try {
      if (kDebugMode) {
        print(
          '💾 [TournamentsDS] Saving ${players.length} team players in bulk',
        );
      }

      final payload = {
        'teamPlayersList': players,
      };

      final response = await _apiClient.post(
        ApiEndpoints.saveTournamentTeamPlayers,
        data: payload,
      );

      _validateResponse(response, 'Failed to add players');

      await _cache.clear('team_players_$teamId');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final obj = data['obj'];
        if (obj is String && obj.toLowerCase().contains('successfully')) {
          if (kDebugMode) {
            print(
              '✅ [TournamentsDS] Players added successfully (Message: $obj)',
            );
          }
          return true;
        }
      }
      return true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to add players: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentTeamPlayersList(
    int teamId,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching players for team: $teamId');
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentTeamPlayersList,
        data: {'teamId': teamId},
      );

      _validateResponse(response, 'Failed to fetch team players');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj is List) {
        return obj.map((e) => e as Map<String, dynamic>).toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to fetch team players: $e');
    }
  }

  Future<bool> deleteTournamentTeamPlayer(int playerId) async {
    if (!_connectivity.isConnected) {
      throw Exception('Internet connection required to remove player.');
    }

    try {
      if (kDebugMode) {
        print('🗑️ [TournamentsDS] Deleting player: $playerId');
      }

      final response = await _apiClient.post(
        ApiEndpoints.deleteTournamentTeamPlayers,
        data: {'id': playerId},
      );

      _validateResponse(response, 'Failed to remove player');
      return true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to remove player: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchUserByQuery(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Searching user: $query');
      }

      final isEmail = query.contains('@');
      final payload = <String, dynamic>{
        'roleId': 4,
        'deleted': false,
        'status': true,
      };
      if (isEmail) {
        payload['email'] = query.trim();
      } else {
        payload['mobile'] = query.trim();
      }

      final response = await _apiClient.post(
        ApiEndpoints.getUsersList,
        data: payload,
        options: Options(
          extra: {'printResponse': false},
        ),
      );

      _validateResponse(response, 'Failed to search users');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj is List) {
        return obj.map((e) => e as Map<String, dynamic>).toList();
      } else if (obj is Map<String, dynamic>) {
        return [obj];
      }

      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] User search error: ${_handleError(e)}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] User search error: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUsersList({
    bool deleted = false,
    bool status = true,
    int roleId = 4,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 [TournamentsDS] Fetching users list with roleId: $roleId');
      }

      final payload = <String, dynamic>{
        'deleted': deleted,
        'status': status,
        'roleId': roleId,
      };

      final response = await _apiClient.post(
        ApiEndpoints.getUsersList,
        data: payload,
        options: Options(
          extra: {'printResponse': false},
        ),
      );

      _validateResponse(response, 'Failed to fetch users list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'];

      if (obj is List) {
        if (kDebugMode) {
          print('✅ [TournamentsDS] Fetched ${obj.length} users');
        }
        return obj.map((e) => e as Map<String, dynamic>).toList();
      } else if (obj is Map<String, dynamic>) {
        return [obj];
      }

      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Users list error: ${_handleError(e)}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Users list error: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentSponsorsList(
    int tournamentId,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🔍 [TournamentsDS] Fetching sponsors for tournament: $tournamentId',
        );
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentSponsorsList,
        data: {'tournamentId': tournamentId, 'deleted': false},
      );

      _validateResponse(response, 'Failed to fetch sponsors list');

      final data = response.data as Map<String, dynamic>;
      final obj = data['obj'] as List<dynamic>?;

      if (obj == null || obj.isEmpty) {
        return [];
      }

      final filtered = obj.where((item) {
        final itemMap = item as Map<String, dynamic>;
        final deleted = itemMap['deleted'] as bool? ?? false;
        return !deleted;
      }).toList();

      if (kDebugMode) {
        print('✅ [TournamentsDS] Fetched ${filtered.length} sponsors');
      }

      return filtered.map((item) => item as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Sponsors error: ${_handleError(e)}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TournamentsDS] Sponsors error: $e');
      }
      return [];
    }
  }

  String getSponsorImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return '';
    }

    final lowerFileName = fileName.toLowerCase();

    if (fileName.contains(' ') ||
        fileName.contains('\n') ||
        fileName.contains('\r') ||
        lowerFileName.contains('error') ||
        lowerFileName.contains('disk') ||
        lowerFileName.contains('space') ||
        lowerFileName.contains('failed') ||
        lowerFileName.contains('exception')) {
      return '';
    }

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final hasValidExtension =
        validExtensions.any((ext) => lowerFileName.endsWith(ext));

    if (!hasValidExtension) {
      return '';
    }

    var url = baseUrl;
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    var path = ApiEndpoints.sponsorUploads;
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    return '$url$path$fileName';
  }
}
