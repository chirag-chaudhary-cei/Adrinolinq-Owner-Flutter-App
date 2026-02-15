import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/location_models.dart';
import '../models/save_user_request.dart';
import '../models/sports_model.dart';
import '../models/type_data_model.dart';

/// Onboarding remote data source - handles all API calls for onboarding
/// Implements cache-first strategy for offline support using Hive
class OnboardingRemoteDataSource {
  OnboardingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;
  HiveCacheManager get _cache => HiveCacheManager.instance;

  /// Validate API response - checks both HTTP status code and response_code
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

  // ========== Cache Getters (for smart cache pattern) ==========

  /// Get cached sports list (for showing instantly while fetching fresh)
  List<SportsModel>? getCachedSportsList() {
    final cached = _cache.getSportsList();
    if (cached != null && cached.isNotEmpty) {
      return cached
          .map((e) => SportsModel.fromJson(e))
          .toList()
          .reversed
          .toList();
    }
    return null;
  }

  /// Get cached countries list
  List<CountryModel>? getCachedCountries() {
    final cached = _cache.getCountries();
    if (cached != null && cached.isNotEmpty) {
      return cached.map((e) => CountryModel.fromJson(e)).toList();
    }
    return null;
  }

  /// Get cached states list for a country
  List<StateModel>? getCachedStates(int countryId) {
    final cached = _cache.getStates(countryId);
    if (cached != null && cached.isNotEmpty) {
      return cached.map((e) => StateModel.fromJson(e)).toList();
    }
    return null;
  }

  /// Get cached type data list
  List<TypeDataItem>? getCachedTypeData(int typeMasterId) {
    final cached = _cache.getTypeData(typeMasterId);
    if (cached != null && cached.isNotEmpty) {
      return cached.map((e) => TypeDataItem.fromJson(e)).toList();
    }
    return null;
  }

  // ========== TypeData API ==========

  /// Get type data list (for dropdowns like gender, blood group, t-shirt size, name title)
  /// Caches data for offline access
  Future<TypeDataResponse> getTypeDataList(int typeMasterId) async {
    try {
      if (kDebugMode) {
        print(
          '🔍 [OnboardingDS] Fetching type data for masterId: $typeMasterId',
        );
      }
      final response = await _apiClient.post(
        ApiEndpoints.getTypeDataList,
        data: {'typeMasterId': typeMasterId},
      );

      _validateResponse(response, 'Failed to load data');
      final typeDataResponse =
          TypeDataResponse.fromJson(response.data as Map<String, dynamic>);

      if (kDebugMode) {
        print(
          '✅ [OnboardingDS] Type data fetched: ${typeDataResponse.items.length} items',
        );
      }

      // Cache the type data for offline access
      final cacheData = typeDataResponse.items.map((e) => e.toJson()).toList();
      await _cache.saveTypeData(typeMasterId, cacheData);
      if (kDebugMode) {
        print('💾 [OnboardingDS] Type data cached for masterId: $typeMasterId');
      }

      return typeDataResponse;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [OnboardingDS] DioException: ${_handleError(e)}');
      }

      // On network error, try to return cached data
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        if (kDebugMode) {
          print(
            '📴 [OnboardingDS] Network error, checking cache for type data...',
          );
        }
        final cachedData = _cache.getTypeData(typeMasterId);
        if (cachedData != null) {
          if (kDebugMode) {
            print('✅ [OnboardingDS] Returning cached type data (offline mode)');
          }
          final items =
              cachedData.map((e) => TypeDataItem.fromJson(e)).toList();
          return TypeDataResponse(items: items);
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [OnboardingDS] Error: $e');
      }
      // Try cache as last resort
      final cachedData = _cache.getTypeData(typeMasterId);
      if (cachedData != null) {
        if (kDebugMode) {
          print('⚠️ [OnboardingDS] Error occurred, returning cached type data');
        }
        final items = cachedData.map((e) => TypeDataItem.fromJson(e)).toList();
        return TypeDataResponse(items: items);
      }
      throw Exception('Failed to load data: ${e.toString()}');
    }
  }

  // ========== Location APIs ==========

  /// Get country list - caches for offline access
  Future<List<CountryModel>> getCountryList() async {
    try {
      print('🔍 [OnboardingDS] Fetching country list...');
      final response = await _apiClient.post(
        ApiEndpoints.getCountryList,
        data: {},
      );

      _validateResponse(response, 'Failed to load countries');

      final obj = response.data['obj'];
      if (obj is List) {
        final countries = obj
            .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print('✅ [OnboardingDS] Countries fetched: ${countries.length} items');
        countries
            .take(5)
            .forEach((c) => print('   - ID: ${c.id}, Name: ${c.name}'));

        // Cache countries for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveCountries(cacheData);
        print('💾 [OnboardingDS] Countries cached for offline access');

        return countries;
      }
      print('⚠️ [OnboardingDS] No countries found in response');
      return [];
    } on DioException catch (e) {
      print('❌ [OnboardingDS] DioException: ${_handleError(e)}');
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getCountries();
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached countries (offline)');
          return cachedData.map((e) => CountryModel.fromJson(e)).toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      print('❌ [OnboardingDS] Error: $e');
      final cachedData = _cache.getCountries();
      if (cachedData != null) {
        return cachedData.map((e) => CountryModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load countries: ${e.toString()}');
    }
  }

  /// Get state list by country - caches for offline access
  Future<List<StateModel>> getStateList(int countryId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getStateList,
        data: {'countryId': countryId},
      );

      _validateResponse(response, 'Failed to load states');

      final obj = response.data['obj'];
      if (obj is List) {
        final states = obj
            .map((e) => StateModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache states for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveStates(countryId, cacheData);
        print('💾 [OnboardingDS] States cached for countryId=$countryId');

        return states;
      }
      return [];
    } on DioException catch (e) {
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getStates(countryId);
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached states (offline)');
          return cachedData.map((e) => StateModel.fromJson(e)).toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedData = _cache.getStates(countryId);
      if (cachedData != null) {
        return cachedData.map((e) => StateModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load states: ${e.toString()}');
    }
  }

  /// Get district list by state - caches for offline access
  Future<List<DistrictModel>> getDistrictList(int stateId) async {
    try {
      print('🔍 [OnboardingDS] Fetching districts for stateId=$stateId');
      final response = await _apiClient.post(
        ApiEndpoints.getDistrictList,
        data: {'stateId': stateId},
      );

      print(
          '🔍 [OnboardingDS] District API response: ${response.data.toString()}');
      _validateResponse(response, 'Failed to load districts');

      final obj = response.data['obj'];
      print(
          '🔍 [OnboardingDS] District obj type: ${obj.runtimeType}, length: ${obj is List ? obj.length : 'N/A'}');

      if (obj is List) {
        final districts = obj
            .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
            .toList();

        print('✅ [OnboardingDS] Parsed ${districts.length} districts');
        if (districts.isNotEmpty) {
          print(
              '📋 [OnboardingDS] Sample: ${districts.first.name} (id=${districts.first.id})');
        }

        // Cache districts for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveDistricts(stateId, cacheData);
        print('💾 [OnboardingDS] Districts cached for stateId=$stateId');

        return districts;
      }
      print('⚠️ [OnboardingDS] District obj is not a list!');
      return [];
    } on DioException catch (e) {
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getDistricts(stateId);
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached districts (offline)');
          return cachedData.map((e) => DistrictModel.fromJson(e)).toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedData = _cache.getDistricts(stateId);
      if (cachedData != null) {
        return cachedData.map((e) => DistrictModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load districts: ${e.toString()}');
    }
  }

  /// Get city list by state (New method: using stateId instead of districtId)
  Future<List<CityModel>> getCityList(int stateId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getCityList,
        data: {'stateId': stateId},
      );

      _validateResponse(response, 'Failed to load cities');

      final obj = response.data['obj'];
      if (obj is List) {
        final cities = obj
            .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache cities for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveCities(stateId, cacheData);
        print('💾 [OnboardingDS] Cities cached for stateId=$stateId');

        return cities;
      }
      return [];
    } on DioException catch (e) {
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getCities(stateId);
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached cities (offline)');
          return cachedData.map((e) => CityModel.fromJson(e)).toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedData = _cache.getCities(stateId);
      if (cachedData != null) {
        return cachedData.map((e) => CityModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load cities: ${e.toString()}');
    }
  }

  /// Get region list by city - caches for offline access
  Future<List<RegionModel>> getRegionList(int cityId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getRegionList,
        data: {'cityId': cityId},
      );

      _validateResponse(response, 'Failed to load regions');

      final obj = response.data['obj'];
      if (obj is List) {
        final regions = obj
            .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache regions for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveRegions(cityId, cacheData);
        print('💾 [OnboardingDS] Regions cached for cityId=$cityId');

        return regions;
      }
      return [];
    } on DioException catch (e) {
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getRegions(cityId);
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached regions (offline)');
          return cachedData.map((e) => RegionModel.fromJson(e)).toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedData = _cache.getRegions(cityId);
      if (cachedData != null) {
        return cachedData.map((e) => RegionModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load regions: ${e.toString()}');
    }
  }

  /// Get community list - caches for offline access
  /// Pass [id] to get a specific community by ID (useful for edit mode)
  Future<List<CommunityModel>> getCommunityList({int? id}) async {
    try {
      print(
        '🔍 [OnboardingDS] Fetching communities${id != null ? ' with id=$id' : ''}...',
      );
      final response = await _apiClient.post(
        ApiEndpoints.getCommunityList,
        data: id != null ? {'id': id} : {},
      );

      _validateResponse(response, 'Failed to load communities');

      final obj = response.data['obj'];
      if (obj is List) {
        final communities = obj
            .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print(
          '✅ [OnboardingDS] Communities fetched: ${communities.length} items',
        );
        if (communities.isNotEmpty && communities.length <= 5) {
          for (var c in communities) {
            print('   - ID: ${c.id}, Name: ${c.name}');
          }
        }

        // Cache communities for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveCommunities(cacheData, id: id);
        print(
          '💾 [OnboardingDS] Communities cached${id != null ? ' for id=$id' : ''}',
        );

        return communities;
      }
      print('⚠️ [OnboardingDS] No communities found in response');
      return [];
    } on DioException catch (e) {
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getCommunities(id: id);
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached communities (offline)');
          return cachedData.map((e) => CommunityModel.fromJson(e)).toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedData = _cache.getCommunities(id: id);
      if (cachedData != null) {
        return cachedData.map((e) => CommunityModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load communities: ${e.toString()}');
    }
  }

  // ========== Sports API ==========

  /// Get sports list - caches for offline access
  Future<List<SportsModel>> getSportsList() async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getSportsList,
        data: {},
      );

      _validateResponse(response, 'Failed to load sports');

      final obj = response.data['obj'];
      if (obj is List) {
        final sports = obj
            .map((e) => SportsModel.fromJson(e as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();

        // Cache sports list for offline access
        final cacheData = obj.cast<Map<String, dynamic>>();
        await _cache.saveSportsList(cacheData);
        print('💾 [OnboardingDS] Sports list cached (${sports.length} items)');

        return sports;
      }
      return [];
    } on DioException catch (e) {
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getSportsList();
        if (cachedData != null) {
          print('✅ [OnboardingDS] Returning cached sports list (offline)');
          return cachedData
              .map((e) => SportsModel.fromJson(e))
              .toList()
              .reversed
              .toList();
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedData = _cache.getSportsList();
      if (cachedData != null) {
        return cachedData
            .map((e) => SportsModel.fromJson(e))
            .toList()
            .reversed
            .toList();
      }
      throw Exception('Failed to load sports: ${e.toString()}');
    }
  }

  /// Get a single sport by id
  Future<SportsModel?> getSportById(int id) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.getSportsList,
        data: {'id': id},
      );

      _validateResponse(response, 'Failed to load sport');

      final obj = response.data['obj'];
      if (obj is List && obj.isNotEmpty) {
        return SportsModel.fromJson(obj.first as Map<String, dynamic>);
      }
      if (obj is Map<String, dynamic>) {
        return SportsModel.fromJson(obj);
      }
      return null;
    } on DioException catch (e) {
      // Try cache fallback
      final cached = _cache.getSportsList();
      if (cached != null) {
        try {
          final found = cached.map((e) => SportsModel.fromJson(e)).firstWhere(
                (s) => s.sportsId == id,
                orElse: () => throw Exception('Not found'),
              );
          return found;
        } catch (_) {
          // fallthrough
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cached = _cache.getSportsList();
      if (cached != null) {
        try {
          return cached
              .map((e) => SportsModel.fromJson(e))
              .firstWhere((s) => s.sportsId == id);
        } catch (_) {
          return null;
        }
      }
      throw Exception('Failed to load sport: ${e.toString()}');
    }
  }

  /// Get sport image URL from imageFile
  String getSportImageUrl(String? imageFile) {
    if (imageFile == null || imageFile.isEmpty) {
      return '';
    }
    return '${_apiClient.baseUrl}${ApiEndpoints.sportsUploads}$imageFile';
  }

  // ========== Save User API ==========

  /// Save user profile
  Future<SaveUserResponse> saveUser(SaveUserRequest request) async {
    try {
      final payload = request.toJson();

      AppLogger.info('Saving user profile', 'OnboardingDataSource');
      print(
        '📤 [SaveUser] Payload includes imageFile: ${payload.containsKey('imageFile') ? payload['imageFile'] : 'NOT INCLUDED'}',
      );

      final response = await _apiClient.post(
        ApiEndpoints.saveUsers,
        data: payload,
      );

      // Check if backend saved imageFile
      if (response.data is Map<String, dynamic>) {
        final obj = response.data['obj'];
        if (obj is Map<String, dynamic>) {
          final returnedImageFile = obj['imageFile'];
          if (returnedImageFile == null ||
              returnedImageFile.toString().isEmpty) {
            print(
              '⚠️ [SaveUser] Backend did NOT save imageFile. We sent: ${payload['imageFile']}',
            );
          }
        }
      }

      _validateResponse(response, 'Failed to save profile');
      return SaveUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to save profile: ${e.toString()}');
    }
  }

  /// Get player sports preferences list - caches for offline access
  Future<List<Map<String, dynamic>>> getPlayerSportsPreferencesList({
    required int playerUserId,
  }) async {
    try {
      print(
        '🔍 [OnboardingDS] Fetching sports preferences for userId=$playerUserId',
      );
      final response = await _apiClient.post(
        '/api/PlayerSportsPreferences/getPlayerSportsPreferencesList',
        data: {'playerUserId': playerUserId},
      );

      _validateResponse(response, 'Failed to load sports preferences');

      final obj = response.data['obj'];
      if (obj is List) {
        final preferences = obj.cast<Map<String, dynamic>>();
        print(
          '✅ [OnboardingDS] Sports preferences fetched: ${preferences.length} items',
        );

        // Cache sports preferences for offline access
        await _cache.saveSportsPreferences(playerUserId, preferences);
        print(
          '💾 [OnboardingDS] Sports preferences cached for userId=$playerUserId',
        );

        return preferences;
      }

      return [];
    } on DioException catch (e) {
      print('❌ [OnboardingDS] DioException: ${_handleError(e)}');
      // Try cache on network error
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedData = _cache.getSportsPreferences(playerUserId);
        if (cachedData != null) {
          print(
            '✅ [OnboardingDS] Returning cached sports preferences (offline)',
          );
          return cachedData;
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      print('❌ [OnboardingDS] Error: $e');
      final cachedData = _cache.getSportsPreferences(playerUserId);
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Failed to load sports preferences: ${e.toString()}');
    }
  }

  /// Clear sports preferences cache for a user
  Future<void> clearSportsPreferencesCache(int userId) async {
    await _cache.clearSportsPreferences(userId);
    print(
      '🗑️ [OnboardingDS] Sports preferences cache cleared for userId=$userId',
    );
  }

  /// Save player sports preferences
  Future<void> savePlayerSportsPreferences({
    // required int playerUserId,
    required int sportId,
    required int levelId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.savePlayerSportsPreferences,
        data: {
          // 'playerUserId': playerUserId,
          'sportId': sportId,
          'levelId': levelId,
        },
      );

      _validateResponse(response, 'Failed to save sports preference');
      print('✅ [OnboardingDS] Sports preference saved successfully');
    } on DioException catch (e) {
      print('❌ [OnboardingDS] DioException: ${_handleError(e)}');
      throw Exception(_handleError(e));
    } catch (e) {
      print('❌ [OnboardingDS] Error: $e');
      throw Exception('Failed to save sports preference: ${e.toString()}');
    }
  }

  /// Save multiple player sports preferences in batch
  Future<void> savePlayerSportsPreferencesBatch({
    required int playerUserId,
    required List<Map<String, dynamic>> sportsPreferences,
  }) async {
    try {
      print(
        '💾 [OnboardingDS] Saving ${sportsPreferences.length} sports preferences in batch for userId=$playerUserId',
      );
      print('📦 Payload: $sportsPreferences');

      // Try to send as array first (preferred)
      try {
        final response = await _apiClient.post(
          ApiEndpoints.savePlayerSportsPreferences,
          data: sportsPreferences,
        );

        _validateResponse(response, 'Failed to save sports preferences');
        print('✅ [OnboardingDS] All sports preferences saved successfully');
        return;
      } catch (e) {
        print(
          '⚠️ [OnboardingDS] Batch save not supported, falling back to individual saves',
        );
      }

      // Fallback: Save each preference individually
      for (var i = 0; i < sportsPreferences.length; i++) {
        final pref = sportsPreferences[i];
        print(
          '💾 Saving preference ${i + 1}/${sportsPreferences.length}: $pref',
        );

        final response = await _apiClient.post(
          ApiEndpoints.savePlayerSportsPreferences,
          data: pref,
        );

        _validateResponse(
          response,
          'Failed to save sports preference for sportId=${pref['sportId']}',
        );
      }

      print(
        '✅ [OnboardingDS] All sports preferences saved successfully (individually)',
      );
    } on DioException catch (e) {
      print('❌ [OnboardingDS] DioException: ${_handleError(e)}');
      throw Exception(_handleError(e));
    } catch (e) {
      print('❌ [OnboardingDS] Error: $e');
      throw Exception('Failed to save sports preferences: ${e.toString()}');
    }
  }
}
