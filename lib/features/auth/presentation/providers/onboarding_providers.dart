import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/cache/smart_cache.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/datasources/onboarding_remote_data_source.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../data/models/type_data_model.dart';
import '../../data/models/location_models.dart';
import '../../data/models/sports_model.dart';

/// Onboarding remote data source provider
final onboardingRemoteDataSourceProvider =
    Provider<OnboardingRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OnboardingRemoteDataSource(apiClient);
});

/// Onboarding repository provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final remoteDataSource = ref.watch(onboardingRemoteDataSourceProvider);
  return OnboardingRepository(remoteDataSource: remoteDataSource);
});

// ========== TypeData Providers ==========

/// Name titles provider (Mr., Mrs., Ms., etc.) - with smart cache
final nameTitlesProvider = FutureProvider<List<TypeDataItem>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedTypeData(TypeMasterId.nameTitle);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    SmartCacheDebug.logFetching();
    Future.microtask(() async {
      try {
        await repository.getNameTitles();
        SmartCacheDebug.logNoChange();
      } catch (e) {
        SmartCacheDebug.logFailed(e);
      }
    });
    return cached;
  }

  SmartCacheDebug.logNoCache();
  return repository.getNameTitles();
});

/// Genders provider - with smart cache
final gendersProvider = FutureProvider<List<TypeDataItem>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedTypeData(TypeMasterId.gender);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    SmartCacheDebug.logFetching();
    Future.microtask(() async {
      try {
        await repository.getGenders();
      } catch (_) {}
    });
    return cached;
  }

  SmartCacheDebug.logNoCache();
  return repository.getGenders();
});

/// Blood groups provider - with smart cache
final bloodGroupsProvider = FutureProvider<List<TypeDataItem>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedTypeData(TypeMasterId.bloodGroup);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    Future.microtask(() async {
      try {
        await repository.getBloodGroups();
      } catch (_) {}
    });
    return cached;
  }

  return repository.getBloodGroups();
});

/// T-shirt sizes provider - with smart cache
final tshirtSizesProvider = FutureProvider<List<TypeDataItem>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedTypeData(TypeMasterId.tshirtSize);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    Future.microtask(() async {
      try {
        await repository.getTshirtSizes();
      } catch (_) {}
    });
    return cached;
  }

  return repository.getTshirtSizes();
});

/// Food preferences provider - with smart cache
final foodPreferencesProvider = FutureProvider<List<TypeDataItem>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedTypeData(TypeMasterId.foodPreference);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    Future.microtask(() async {
      try {
        await repository.getFoodPreferences();
      } catch (_) {}
    });
    return cached;
  }

  return repository.getFoodPreferences();
});

// ========== Location Providers ==========

/// Countries provider
final countriesProvider = FutureProvider<List<CountryModel>>((ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getCountries();
});

/// States provider - depends on selected country
final statesProvider =
    FutureProvider.family<List<StateModel>, int>((ref, countryId) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getStates(countryId);
});

/// Districts provider - depends on selected state
final districtsProvider =
    FutureProvider.family<List<DistrictModel>, int>((ref, stateId) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getDistricts(stateId);
});

/// Cities provider - depends on selected district
final citiesProvider =
    FutureProvider.family<List<CityModel>, int>((ref, districtId) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getCities(districtId);
});

/// Regions provider - depends on selected city
final regionsProvider =
    FutureProvider.family<List<RegionModel>, int>((ref, cityId) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getRegions(cityId);
});

/// Communities provider
final communitiesProvider = FutureProvider.family<List<CommunityModel>, int?>(
  (ref, id) async {
    final repository = ref.watch(onboardingRepositoryProvider);
    return repository.getCommunities(id: id);
  },
);

// ========== Sports Providers ==========

/// Sports list provider - with smart cache
final sportsListProvider = FutureProvider<List<dynamic>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedSportsList();
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    SmartCacheDebug.logFetching();

    Future.microtask(() async {
      try {
        final fresh = await repository.getSportsList();
        final hasChanged = cached.length != fresh.length;
        if (hasChanged) {
          SmartCacheDebug.logDataChanged(cached.length, fresh.length);
          ref.invalidateSelf();
        } else {
          SmartCacheDebug.logNoChange();
        }
      } catch (e) {
        SmartCacheDebug.logFailed(e);
      }
    });

    return cached;
  }

  SmartCacheDebug.logNoCache();
  return repository.getSportsList();
});

/// Single sport provider by id
final sportByIdProvider =
    FutureProvider.family<SportsModel?, int>((ref, sportId) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getSportById(sportId);
});

/// Proficiency levels provider (typeMasterId: 10)
final proficiencyLevelsProvider =
    FutureProvider<List<TypeDataItem>>((ref) async {
  final dataSource = ref.watch(onboardingRemoteDataSourceProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final cached = dataSource.getCachedTypeData(10);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    Future.microtask(() async {
      try {
        await repository.getProficiencyLevels();
      } catch (_) {}
    });
    return cached;
  }

  return repository.getProficiencyLevels();
});
