import 'dart:convert';
import '../storage/local_storage.dart';
import 'cache_keys.dart';

/// Cache manager for offline data storage
/// Provides cache-first strategy for API data
class CacheManager {
  CacheManager._();

  static CacheManager? _instance;

  /// Singleton instance
  static CacheManager get instance {
    _instance ??= CacheManager._();
    return _instance!;
  }

  LocalStorage get _storage => LocalStorage.instance;

  // ========== Generic Cache Operations ==========

  /// Save data to cache with timestamp
  Future<bool> save(String key, dynamic data) async {
    try {
      final jsonString = json.encode(data);
      final saved = await _storage.setString(key, jsonString);
      if (saved) {
        // Save timestamp
        await _storage.setInt(
          CacheKeys.timestamp(key),
          DateTime.now().millisecondsSinceEpoch,
        );
      }
      return saved;
    } catch (e) {
      print('❌ [CacheManager] Failed to save $key: $e');
      return false;
    }
  }

  /// Get data from cache
  T? get<T>(String key) {
    try {
      final jsonString = _storage.getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString) as T;
    } catch (e) {
      print('❌ [CacheManager] Failed to get $key: $e');
      return null;
    }
  }

  /// Get list data from cache
  List<Map<String, dynamic>>? getList(String key) {
    try {
      final jsonString = _storage.getString(key);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      return null;
    } catch (e) {
      print('❌ [CacheManager] Failed to get list $key: $e');
      return null;
    }
  }

  /// Check if cache is valid (not expired)
  bool isValid(String key, {Duration? maxAge}) {
    final timestamp = _storage.getInt(CacheKeys.timestamp(key));
    if (timestamp == null) return false;

    final age = maxAge ?? CacheKeys.defaultCacheDuration;
    final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    return now.difference(savedTime) < age;
  }

  /// Check if cache exists (regardless of expiry)
  bool exists(String key) {
    return _storage.containsKey(key);
  }

  /// Clear specific cache
  Future<bool> clear(String key) async {
    try {
      await _storage.remove(key);
      await _storage.remove(CacheKeys.timestamp(key));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    final keys = _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await _storage.remove(key);
      }
    }
  }

  // ========== Profile Cache ==========

  Future<bool> saveProfile(Map<String, dynamic> profile) async {
    return save(CacheKeys.userProfile, profile);
  }

  Map<String, dynamic>? getProfile() {
    return get<Map<String, dynamic>>(CacheKeys.userProfile);
  }

  bool hasValidProfile() {
    return isValid(CacheKeys.userProfile);
  }

  bool hasProfile() {
    return exists(CacheKeys.userProfile);
  }

  // ========== Type Data Cache ==========

  Future<bool> saveTypeData(
      int typeMasterId, List<Map<String, dynamic>> items,) async {
    return save(CacheKeys.typeData(typeMasterId), items);
  }

  List<Map<String, dynamic>>? getTypeData(int typeMasterId) {
    return getList(CacheKeys.typeData(typeMasterId));
  }

  bool hasValidTypeData(int typeMasterId) {
    return isValid(CacheKeys.typeData(typeMasterId),
        maxAge: CacheKeys.longCacheDuration,);
  }

  bool hasTypeData(int typeMasterId) {
    return exists(CacheKeys.typeData(typeMasterId));
  }

  // ========== Location Cache ==========

  Future<bool> saveCountries(List<Map<String, dynamic>> countries) async {
    return save(CacheKeys.countries, countries);
  }

  List<Map<String, dynamic>>? getCountries() {
    return getList(CacheKeys.countries);
  }

  bool hasValidCountries() {
    return isValid(CacheKeys.countries, maxAge: CacheKeys.longCacheDuration);
  }

  bool hasCountries() {
    return exists(CacheKeys.countries);
  }

  Future<bool> saveStates(
      int countryId, List<Map<String, dynamic>> states,) async {
    return save(CacheKeys.states(countryId), states);
  }

  List<Map<String, dynamic>>? getStates(int countryId) {
    return getList(CacheKeys.states(countryId));
  }

  bool hasValidStates(int countryId) {
    return isValid(CacheKeys.states(countryId),
        maxAge: CacheKeys.longCacheDuration,);
  }

  bool hasStates(int countryId) {
    return exists(CacheKeys.states(countryId));
  }

  Future<bool> saveDistricts(
      int stateId, List<Map<String, dynamic>> districts,) async {
    return save(CacheKeys.districts(stateId), districts);
  }

  List<Map<String, dynamic>>? getDistricts(int stateId) {
    return getList(CacheKeys.districts(stateId));
  }

  bool hasValidDistricts(int stateId) {
    return isValid(CacheKeys.districts(stateId),
        maxAge: CacheKeys.longCacheDuration,);
  }

  bool hasDistricts(int stateId) {
    return exists(CacheKeys.districts(stateId));
  }

  Future<bool> saveCities(
      int districtId, List<Map<String, dynamic>> cities,) async {
    return save(CacheKeys.cities(districtId), cities);
  }

  List<Map<String, dynamic>>? getCities(int districtId) {
    return getList(CacheKeys.cities(districtId));
  }

  bool hasValidCities(int districtId) {
    return isValid(CacheKeys.cities(districtId),
        maxAge: CacheKeys.longCacheDuration,);
  }

  bool hasCities(int districtId) {
    return exists(CacheKeys.cities(districtId));
  }

  Future<bool> saveRegions(
      int cityId, List<Map<String, dynamic>> regions,) async {
    return save(CacheKeys.regions(cityId), regions);
  }

  List<Map<String, dynamic>>? getRegions(int cityId) {
    return getList(CacheKeys.regions(cityId));
  }

  bool hasValidRegions(int cityId) {
    return isValid(CacheKeys.regions(cityId),
        maxAge: CacheKeys.longCacheDuration,);
  }

  bool hasRegions(int cityId) {
    return exists(CacheKeys.regions(cityId));
  }

  Future<bool> saveCommunities(List<Map<String, dynamic>> communities,
      {int? id,}) async {
    if (id != null) {
      return save(CacheKeys.community(id), communities);
    }
    return save(CacheKeys.communities, communities);
  }

  List<Map<String, dynamic>>? getCommunities({int? id}) {
    if (id != null) {
      return getList(CacheKeys.community(id));
    }
    return getList(CacheKeys.communities);
  }

  bool hasValidCommunities({int? id}) {
    if (id != null) {
      return isValid(CacheKeys.community(id),
          maxAge: CacheKeys.longCacheDuration,);
    }
    return isValid(CacheKeys.communities, maxAge: CacheKeys.longCacheDuration);
  }

  bool hasCommunities({int? id}) {
    if (id != null) {
      return exists(CacheKeys.community(id));
    }
    return exists(CacheKeys.communities);
  }

  // ========== Sports Cache ==========

  Future<bool> saveSportsList(List<Map<String, dynamic>> sports) async {
    return save(CacheKeys.sportsList, sports);
  }

  List<Map<String, dynamic>>? getSportsList() {
    return getList(CacheKeys.sportsList);
  }

  bool hasValidSportsList() {
    return isValid(CacheKeys.sportsList, maxAge: CacheKeys.longCacheDuration);
  }

  bool hasSportsList() {
    return exists(CacheKeys.sportsList);
  }

  Future<bool> saveSportsPreferences(
      int userId, List<Map<String, dynamic>> preferences,) async {
    return save(CacheKeys.sportsPreferences(userId), preferences);
  }

  List<Map<String, dynamic>>? getSportsPreferences(int userId) {
    return getList(CacheKeys.sportsPreferences(userId));
  }

  bool hasValidSportsPreferences(int userId) {
    return isValid(CacheKeys.sportsPreferences(userId));
  }

  bool hasSportsPreferences(int userId) {
    return exists(CacheKeys.sportsPreferences(userId));
  }
}
