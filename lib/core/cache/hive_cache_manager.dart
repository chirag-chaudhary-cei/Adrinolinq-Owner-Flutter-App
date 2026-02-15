import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'hive_boxes.dart';

/// Hive-based cache manager for offline-first data storage
/// Provides cache-first strategy with background refresh
class HiveCacheManager {
  HiveCacheManager._();

  static HiveCacheManager? _instance;
  static bool _isInitialized = false;

  /// Singleton instance
  static HiveCacheManager get instance {
    if (!_isInitialized) {
      throw StateError(
        'HiveCacheManager not initialized. Call HiveCacheManager.initialize() in main() before using.',
      );
    }
    _instance ??= HiveCacheManager._();
    return _instance!;
  }

  /// Check if initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Open all boxes
      for (final boxName in HiveBoxes.allBoxes) {
        await Hive.openBox<dynamic>(boxName);
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('✅ [HiveCacheManager] Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HiveCacheManager] Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Close all boxes (call on app dispose if needed)
  static Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
    _instance = null;
  }

  // ========== Box Accessors ==========

  Box<dynamic> get _cacheBox => Hive.box(HiveBoxes.cacheBox);
  Box<dynamic> get _timestampsBox => Hive.box(HiveBoxes.timestampsBox);
  Box<dynamic> get _authBox => Hive.box(HiveBoxes.authBox);

  // ========== Generic Cache Operations ==========

  /// Save data to cache with timestamp
  Future<void> save(String key, dynamic data, {String? boxName}) async {
    try {
      final box = boxName != null ? Hive.box(boxName) : _cacheBox;

      // Convert to JSON string for complex objects
      if (data is Map || data is List) {
        final jsonString = json.encode(data);
        await box.put(key, jsonString);
      } else {
        await box.put(key, data);
      }

      // Save timestamp
      await _timestampsBox.put(
        HiveCacheKeys.timestamp(key),
        DateTime.now().millisecondsSinceEpoch,
      );

      if (kDebugMode) {
        print('💾 [HiveCacheManager] Saved: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HiveCacheManager] Failed to save $key: $e');
      }
    }
  }

  /// Get data from cache
  T? get<T>(String key, {String? boxName}) {
    try {
      final box = boxName != null ? Hive.box(boxName) : _cacheBox;
      final data = box.get(key);

      if (data == null) return null;

      // If it's a JSON string, decode it
      if (data is String) {
        try {
          final decoded = json.decode(data);
          return decoded as T;
        } catch (_) {
          // Not a JSON string, return as is
          return data as T;
        }
      }

      return data as T;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HiveCacheManager] Failed to get $key: $e');
      }
      return null;
    }
  }

  /// Get list data from cache
  List<Map<String, dynamic>>? getList(String key, {String? boxName}) {
    try {
      final box = boxName != null ? Hive.box(boxName) : _cacheBox;
      final data = box.get(key);

      if (data == null) return null;

      if (data is String) {
        final decoded = json.decode(data);
        if (decoded is List) {
          return decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HiveCacheManager] Failed to get list $key: $e');
      }
      return null;
    }
  }

  /// Check if cache is valid (not expired)
  bool isValid(String key, {Duration? maxAge}) {
    final timestamp = _timestampsBox.get(HiveCacheKeys.timestamp(key));
    if (timestamp == null) return false;

    final age = maxAge ?? HiveCacheKeys.defaultCacheDuration;
    final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final now = DateTime.now();

    return now.difference(savedTime) < age;
  }

  /// Check if cache exists (regardless of expiry)
  bool exists(String key, {String? boxName}) {
    final box = boxName != null ? Hive.box(boxName) : _cacheBox;
    return box.containsKey(key);
  }

  /// Get cache timestamp
  DateTime? getTimestamp(String key) {
    final timestamp = _timestampsBox.get(HiveCacheKeys.timestamp(key));
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp as int);
  }

  /// Clear specific cache
  Future<void> clear(String key, {String? boxName}) async {
    try {
      final box = boxName != null ? Hive.box(boxName) : _cacheBox;
      await box.delete(key);
      await _timestampsBox.delete(HiveCacheKeys.timestamp(key));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HiveCacheManager] Failed to clear $key: $e');
      }
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      for (final boxName in HiveBoxes.allBoxes) {
        final box = Hive.box(boxName);
        await box.clear();
      }
      if (kDebugMode) {
        print('🗑️ [HiveCacheManager] All cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HiveCacheManager] Failed to clear all: $e');
      }
    }
  }

  // ========== Profile Cache ==========

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await save(HiveCacheKeys.userProfile, profile,
        boxName: HiveBoxes.profileBox,);
  }

  Map<String, dynamic>? getProfile() {
    return get<Map<String, dynamic>>(HiveCacheKeys.userProfile,
        boxName: HiveBoxes.profileBox,);
  }

  bool hasValidProfile() {
    return exists(HiveCacheKeys.userProfile, boxName: HiveBoxes.profileBox) &&
        isValid(HiveCacheKeys.userProfile);
  }

  bool hasProfile() {
    return exists(HiveCacheKeys.userProfile, boxName: HiveBoxes.profileBox);
  }

  Future<void> clearProfile() async {
    await clear(HiveCacheKeys.userProfile, boxName: HiveBoxes.profileBox);
  }

  // ========== Type Data Cache ==========

  Future<void> saveTypeData(
      int typeMasterId, List<Map<String, dynamic>> items,) async {
    await save(HiveCacheKeys.typeData(typeMasterId), items);
  }

  List<Map<String, dynamic>>? getTypeData(int typeMasterId) {
    return getList(HiveCacheKeys.typeData(typeMasterId));
  }

  bool hasValidTypeData(int typeMasterId) {
    return exists(HiveCacheKeys.typeData(typeMasterId)) &&
        isValid(HiveCacheKeys.typeData(typeMasterId),
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasTypeData(int typeMasterId) {
    return exists(HiveCacheKeys.typeData(typeMasterId));
  }

  // ========== Location Cache ==========

  Future<void> saveCountries(List<Map<String, dynamic>> countries) async {
    await save(HiveCacheKeys.countries, countries);
  }

  List<Map<String, dynamic>>? getCountries() {
    return getList(HiveCacheKeys.countries);
  }

  bool hasValidCountries() {
    return exists(HiveCacheKeys.countries) &&
        isValid(HiveCacheKeys.countries,
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasCountries() {
    return exists(HiveCacheKeys.countries);
  }

  Future<void> saveStates(
      int countryId, List<Map<String, dynamic>> states,) async {
    await save(HiveCacheKeys.states(countryId), states);
  }

  List<Map<String, dynamic>>? getStates(int countryId) {
    return getList(HiveCacheKeys.states(countryId));
  }

  bool hasValidStates(int countryId) {
    return exists(HiveCacheKeys.states(countryId)) &&
        isValid(HiveCacheKeys.states(countryId),
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasStates(int countryId) {
    return exists(HiveCacheKeys.states(countryId));
  }

  Future<void> saveDistricts(
      int stateId, List<Map<String, dynamic>> districts,) async {
    await save(HiveCacheKeys.districts(stateId), districts);
  }

  List<Map<String, dynamic>>? getDistricts(int stateId) {
    return getList(HiveCacheKeys.districts(stateId));
  }

  bool hasValidDistricts(int stateId) {
    return exists(HiveCacheKeys.districts(stateId)) &&
        isValid(HiveCacheKeys.districts(stateId),
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasDistricts(int stateId) {
    return exists(HiveCacheKeys.districts(stateId));
  }

  Future<void> saveCities(
      int districtId, List<Map<String, dynamic>> cities,) async {
    await save(HiveCacheKeys.cities(districtId), cities);
  }

  List<Map<String, dynamic>>? getCities(int districtId) {
    return getList(HiveCacheKeys.cities(districtId));
  }

  bool hasValidCities(int districtId) {
    return exists(HiveCacheKeys.cities(districtId)) &&
        isValid(HiveCacheKeys.cities(districtId),
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasCities(int districtId) {
    return exists(HiveCacheKeys.cities(districtId));
  }

  Future<void> saveRegions(
      int cityId, List<Map<String, dynamic>> regions,) async {
    await save(HiveCacheKeys.regions(cityId), regions);
  }

  List<Map<String, dynamic>>? getRegions(int cityId) {
    return getList(HiveCacheKeys.regions(cityId));
  }

  bool hasValidRegions(int cityId) {
    return exists(HiveCacheKeys.regions(cityId)) &&
        isValid(HiveCacheKeys.regions(cityId),
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasRegions(int cityId) {
    return exists(HiveCacheKeys.regions(cityId));
  }

  Future<void> saveCommunities(List<Map<String, dynamic>> communities,
      {int? id,}) async {
    if (id != null) {
      await save(HiveCacheKeys.community(id), communities);
    } else {
      await save(HiveCacheKeys.communities, communities);
    }
  }

  List<Map<String, dynamic>>? getCommunities({int? id}) {
    if (id != null) {
      return getList(HiveCacheKeys.community(id));
    }
    return getList(HiveCacheKeys.communities);
  }

  bool hasValidCommunities({int? id}) {
    final key =
        id != null ? HiveCacheKeys.community(id) : HiveCacheKeys.communities;
    return exists(key) && isValid(key, maxAge: HiveCacheKeys.longCacheDuration);
  }

  bool hasCommunities({int? id}) {
    final key =
        id != null ? HiveCacheKeys.community(id) : HiveCacheKeys.communities;
    return exists(key);
  }

  // ========== Sports Cache ==========

  Future<void> saveSportsList(List<Map<String, dynamic>> sports) async {
    await save(HiveCacheKeys.sportsList, sports);
  }

  List<Map<String, dynamic>>? getSportsList() {
    return getList(HiveCacheKeys.sportsList);
  }

  bool hasValidSportsList() {
    return exists(HiveCacheKeys.sportsList) &&
        isValid(HiveCacheKeys.sportsList,
            maxAge: HiveCacheKeys.longCacheDuration,);
  }

  bool hasSportsList() {
    return exists(HiveCacheKeys.sportsList);
  }

  Future<void> saveSportsPreferences(
      int userId, List<Map<String, dynamic>> preferences,) async {
    await save(HiveCacheKeys.sportsPreferences(userId), preferences);
  }

  List<Map<String, dynamic>>? getSportsPreferences(int userId) {
    return getList(HiveCacheKeys.sportsPreferences(userId));
  }

  bool hasValidSportsPreferences(int userId) {
    return exists(HiveCacheKeys.sportsPreferences(userId)) &&
        isValid(HiveCacheKeys.sportsPreferences(userId));
  }

  bool hasSportsPreferences(int userId) {
    return exists(HiveCacheKeys.sportsPreferences(userId));
  }

  Future<void> clearSportsPreferences(int userId) async {
    await clear(HiveCacheKeys.sportsPreferences(userId));
    if (kDebugMode) {
      print(
          '🗑️ [HiveCacheManager] Cleared sports preferences for user $userId',);
    }
  }

  // ========== Tournaments Cache ==========

  Future<void> saveTournamentsList(
      List<Map<String, dynamic>> tournaments,) async {
    await save(HiveCacheKeys.tournamentsList, tournaments,
        boxName: HiveBoxes.tournamentsBox,);
  }

  List<Map<String, dynamic>>? getTournamentsList() {
    return getList(HiveCacheKeys.tournamentsList,
        boxName: HiveBoxes.tournamentsBox,);
  }

  bool hasValidTournamentsList() {
    return exists(HiveCacheKeys.tournamentsList,
            boxName: HiveBoxes.tournamentsBox,) &&
        isValid(HiveCacheKeys.tournamentsList,
            maxAge: HiveCacheKeys.tournamentCacheDuration,);
  }

  bool hasTournamentsList() {
    return exists(HiveCacheKeys.tournamentsList,
        boxName: HiveBoxes.tournamentsBox,);
  }

  Future<void> saveTournamentDetail(
      int id, Map<String, dynamic> tournament,) async {
    await save(HiveCacheKeys.tournamentDetail(id), tournament,
        boxName: HiveBoxes.tournamentsBox,);
  }

  Map<String, dynamic>? getTournamentDetail(int id) {
    return get<Map<String, dynamic>>(HiveCacheKeys.tournamentDetail(id),
        boxName: HiveBoxes.tournamentsBox,);
  }

  Future<void> saveTeamsList(
      int tournamentId, List<Map<String, dynamic>> teams,) async {
    await save(HiveCacheKeys.teamsList(tournamentId), teams,
        boxName: HiveBoxes.tournamentsBox,);
  }

  List<Map<String, dynamic>>? getTeamsList(int tournamentId) {
    return getList(HiveCacheKeys.teamsList(tournamentId),
        boxName: HiveBoxes.tournamentsBox,);
  }

  bool hasTeamsList(int tournamentId) {
    return exists(HiveCacheKeys.teamsList(tournamentId),
        boxName: HiveBoxes.tournamentsBox,);
  }

  Future<void> saveTeamPlayersList(
      int teamId, List<Map<String, dynamic>> players,) async {
    await save(HiveCacheKeys.teamPlayersList(teamId), players,
        boxName: HiveBoxes.tournamentsBox,);
  }

  List<Map<String, dynamic>>? getTeamPlayersList(int teamId) {
    return getList(HiveCacheKeys.teamPlayersList(teamId),
        boxName: HiveBoxes.tournamentsBox,);
  }

  bool hasTeamPlayersList(int teamId) {
    return exists(HiveCacheKeys.teamPlayersList(teamId),
        boxName: HiveBoxes.tournamentsBox,);
  }

  Future<void> saveTournamentRegistrations(
      List<Map<String, dynamic>> registrations,) async {
    await save(HiveCacheKeys.tournamentRegistrations, registrations,
        boxName: HiveBoxes.tournamentsBox,);
  }

  List<Map<String, dynamic>>? getTournamentRegistrations() {
    return getList(HiveCacheKeys.tournamentRegistrations,
        boxName: HiveBoxes.tournamentsBox,);
  }

  bool hasTournamentRegistrations() {
    return exists(HiveCacheKeys.tournamentRegistrations,
        boxName: HiveBoxes.tournamentsBox,);
  }

  // ========== Auth Cache ==========

  Future<void> saveAuthToken(String token) async {
    await _authBox.put(HiveCacheKeys.authToken, token);
    await _authBox.put(
        HiveCacheKeys.lastLoginTime, DateTime.now().millisecondsSinceEpoch,);
  }

  String? getAuthToken() {
    return _authBox.get(HiveCacheKeys.authToken) as String?;
  }

  Future<void> saveRefreshToken(String token) async {
    await _authBox.put(HiveCacheKeys.refreshToken, token);
  }

  String? getRefreshToken() {
    return _authBox.get(HiveCacheKeys.refreshToken) as String?;
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    await _authBox.put(HiveCacheKeys.isLoggedIn, isLoggedIn);
  }

  bool isLoggedIn() {
    return _authBox.get(HiveCacheKeys.isLoggedIn, defaultValue: false) as bool;
  }

  Future<void> clearAuthData() async {
    await _authBox.clear();
  }

  DateTime? getLastLoginTime() {
    final timestamp = _authBox.get(HiveCacheKeys.lastLoginTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp as int);
  }

  /// Save user ID for offline access
  Future<void> saveUserId(int userId) async {
    await _authBox.put(HiveCacheKeys.userId, userId);
  }

  /// Get cached user ID
  int? getUserId() {
    return _authBox.get(HiveCacheKeys.userId) as int?;
  }
}
