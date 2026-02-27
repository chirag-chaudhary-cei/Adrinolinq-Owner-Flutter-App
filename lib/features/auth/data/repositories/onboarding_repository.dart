import '../datasources/onboarding_remote_data_source.dart';
import '../models/location_models.dart';
import '../models/save_user_request.dart';
import '../models/type_data_model.dart';
import '../models/sports_model.dart';

/// Onboarding repository - business logic layer for onboarding
class OnboardingRepository {
  OnboardingRepository({
    required OnboardingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final OnboardingRemoteDataSource _remoteDataSource;

  // ========== TypeData ==========

  /// Get name titles (Mr., Mrs., Ms., etc.)
  Future<List<TypeDataItem>> getNameTitles() async {
    final response =
        await _remoteDataSource.getTypeDataList(TypeMasterId.nameTitle);
    if (response.success) {
      return response.items;
    }
    throw Exception(response.message ?? 'Failed to load name titles');
  }

  /// Get genders
  Future<List<TypeDataItem>> getGenders() async {
    final response =
        await _remoteDataSource.getTypeDataList(TypeMasterId.gender);
    if (response.success) {
      return response.items;
    }
    throw Exception(response.message ?? 'Failed to load genders');
  }

  /// Get blood groups
  Future<List<TypeDataItem>> getBloodGroups() async {
    final response =
        await _remoteDataSource.getTypeDataList(TypeMasterId.bloodGroup);
    if (response.success) {
      return response.items;
    }
    throw Exception(response.message ?? 'Failed to load blood groups');
  }

  /// Get t-shirt sizes
  Future<List<TypeDataItem>> getTshirtSizes() async {
    final response =
        await _remoteDataSource.getTypeDataList(TypeMasterId.tshirtSize);
    if (response.success) {
      return response.items;
    }
    throw Exception(response.message ?? 'Failed to load t-shirt sizes');
  }

  /// Get food preferences
  Future<List<TypeDataItem>> getFoodPreferences() async {
    final response =
        await _remoteDataSource.getTypeDataList(TypeMasterId.foodPreference);
    if (response.success) {
      return response.items;
    }
    throw Exception(response.message ?? 'Failed to load food preferences');
  }

  // ========== Location ==========

  /// Get countries
  Future<List<CountryModel>> getCountries() async {
    return _remoteDataSource.getCountryList();
  }

  /// Get states by country
  Future<List<StateModel>> getStates(int countryId) async {
    return _remoteDataSource.getStateList(countryId);
  }

  /// Get districts by state
  Future<List<DistrictModel>> getDistricts(int stateId) async {
    return _remoteDataSource.getDistrictList(stateId);
  }

  /// Get cities by districtId
  Future<List<CityModel>> getCities(int districtId) async {
    return _remoteDataSource.getCityList(districtId);
  }

  /// Get regions by city
  Future<List<RegionModel>> getRegions(int cityId) async {
    return _remoteDataSource.getRegionList(cityId);
  }

  /// Get communities
  /// Pass [id] to get a specific community by ID (useful for edit mode)
  Future<List<CommunityModel>> getCommunities({int? id}) async {
    return _remoteDataSource.getCommunityList(id: id);
  }

  // ========== Save User ==========

  /// Save user profile
  Future<SaveUserResponse> saveUser(SaveUserRequest request) async {
    return _remoteDataSource.saveUser(request);
  }

  // ========== Sports ==========

  /// Get sports list
  Future<List<dynamic>> getSportsList() async {
    return _remoteDataSource.getSportsList();
  }

  /// Get a single sport by id
  Future<SportsModel?> getSportById(int id) async {
    return _remoteDataSource.getSportById(id);
  }

  /// Get proficiency levels (typeMasterId: 10)
  Future<List<TypeDataItem>> getProficiencyLevels() async {
    final response = await _remoteDataSource.getTypeDataList(10);
    if (response.success) {
      return response.items;
    }
    throw Exception(response.message ?? 'Failed to load proficiency levels');
  }

  /// Save player sports preferences
  Future<List<Map<String, dynamic>>> getPlayerSportsPreferencesList({
    required int playerUserId,
  }) async {
    return _remoteDataSource.getPlayerSportsPreferencesList(
      playerUserId: playerUserId,
    );
  }

  /// Clear sports preferences cache for a user
  Future<void> clearSportsPreferencesCache(int userId) async {
    return _remoteDataSource.clearSportsPreferencesCache(userId);
  }

  Future<void> savePlayerSportsPreferences({
    required int playerUserId,
    required int sportId,
    required int levelId,
  }) async {
    return _remoteDataSource.savePlayerSportsPreferences(
      // playerUserId: playerUserId,
      sportId: sportId,
      levelId: levelId,
    );
  }

  /// Save multiple player sports preferences in batch
  Future<void> savePlayerSportsPreferencesBatch({
    required int playerUserId,
    required List<Map<String, dynamic>> sportsPreferences,
  }) async {
    return _remoteDataSource.savePlayerSportsPreferencesBatch(
      playerUserId: playerUserId,
      sportsPreferences: sportsPreferences,
    );
  }
}
