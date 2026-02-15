import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';

/// Auth remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

/// Local storage provider
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  return await LocalStorage.getInstance();
});

/// Auth repository provider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localStorage = await ref.watch(localStorageProvider.future);
  final secureStorage = SecureStorage.instance;

  return AuthRepository(
    remoteDataSource: remoteDataSource,
    localStorage: localStorage,
    secureStorage: secureStorage,
  );
});
