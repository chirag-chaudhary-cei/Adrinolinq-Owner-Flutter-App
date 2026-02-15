/// Cache key constants for offline data storage
class CacheKeys {
  CacheKeys._();

  // ========== Profile ==========
  static const String userProfile = 'cache_user_profile';
  static const String userProfileTimestamp = 'cache_user_profile_timestamp';

  // ========== Type Data (Dropdowns) ==========
  static const String nameTitles = 'cache_name_titles'; // typeMasterId = 1
  static const String genders = 'cache_genders'; // typeMasterId = 2
  static const String bloodGroups = 'cache_blood_groups'; // typeMasterId = 16
  static const String tshirtSizes = 'cache_tshirt_sizes'; // typeMasterId = 17
  static const String proficiencyLevels =
      'cache_proficiency_levels'; // typeMasterId = 18

  /// Get cache key for type data by masterId
  static String typeData(int typeMasterId) => 'cache_type_data_$typeMasterId';

  // ========== Location Data ==========
  static const String countries = 'cache_countries';

  /// States by country ID
  static String states(int countryId) => 'cache_states_$countryId';

  /// Districts by state ID
  static String districts(int stateId) => 'cache_districts_$stateId';

  /// Cities by district ID
  static String cities(int districtId) => 'cache_cities_$districtId';

  /// Regions by city ID
  static String regions(int cityId) => 'cache_regions_$cityId';

  /// All communities
  static const String communities = 'cache_communities';

  /// Specific community by ID
  static String community(int id) => 'cache_community_$id';

  // ========== Sports ==========
  static const String sportsList = 'cache_sports_list';

  /// Sports preferences by user ID
  static String sportsPreferences(int userId) =>
      'cache_sports_preferences_$userId';

  // ========== Timestamps ==========
  /// Get timestamp key for any cache key
  static String timestamp(String cacheKey) => '${cacheKey}_timestamp';

  // ========== Cache Duration ==========
  /// Default cache duration (24 hours)
  static const Duration defaultCacheDuration = Duration(hours: 24);

  /// Long-lived cache (7 days) - for rarely changing data like countries
  static const Duration longCacheDuration = Duration(days: 7);

  /// Short-lived cache (1 hour) - for frequently changing data
  static const Duration shortCacheDuration = Duration(hours: 1);
}
