/// Hive box names and configuration for offline-first caching
class HiveBoxes {
  HiveBoxes._();

  // ========== Box Names ==========

  /// General cache box for all JSON data
  static const String cacheBox = 'cache_box';

  /// Timestamps box for cache expiration
  static const String timestampsBox = 'timestamps_box';

  /// User profile box
  static const String profileBox = 'profile_box';

  /// Tournaments box
  static const String tournamentsBox = 'tournaments_box';

  /// Auth tokens box (for offline authentication)
  static const String authBox = 'auth_box';

  /// All box names for initialization
  static List<String> get allBoxes => [
        cacheBox,
        timestampsBox,
        profileBox,
        tournamentsBox,
        authBox,
      ];
}

/// Cache key constants for Hive storage
class HiveCacheKeys {
  HiveCacheKeys._();

  // ========== Profile ==========
  static const String userProfile = 'user_profile';
  static const String userId = 'user_id';

  // ========== Type Data (Dropdowns) ==========
  static String typeData(int typeMasterId) => 'type_data_$typeMasterId';

  // ========== Location Data ==========
  static const String countries = 'countries';
  static String states(int countryId) => 'states_$countryId';
  static String districts(int stateId) => 'districts_$stateId';
  static String cities(int districtId) => 'cities_$districtId';
  static String regions(int cityId) => 'regions_$cityId';
  static const String communities = 'communities';
  static String community(int id) => 'community_$id';

  // ========== Sports ==========
  static const String sportsList = 'sports_list';
  static String sportsPreferences(int userId) => 'sports_preferences_$userId';

  // ========== Tournaments ==========
  static const String tournamentsList = 'tournaments_list';
  static String tournamentDetail(int id) => 'tournament_$id';
  static String teamsList(int tournamentId) => 'teams_$tournamentId';
  static String teamPlayersList(int teamId) => 'team_players_$teamId';
  static const String tournamentRegistrations = 'tournament_registrations';

  // ========== Auth ==========
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLoginTime = 'last_login_time';

  // ========== Timestamps ==========
  static String timestamp(String key) => '${key}_timestamp';

  // ========== Cache Duration ==========
  /// Default cache duration (24 hours)
  static const Duration defaultCacheDuration = Duration(hours: 24);

  /// Long-lived cache (7 days) - for rarely changing data
  static const Duration longCacheDuration = Duration(days: 7);

  /// Short-lived cache (1 hour) - for frequently changing data
  static const Duration shortCacheDuration = Duration(hours: 1);

  /// Tournament cache duration (6 hours)
  static const Duration tournamentCacheDuration = Duration(hours: 6);
}
