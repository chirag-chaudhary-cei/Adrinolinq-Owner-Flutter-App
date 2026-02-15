import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../api/api_client.dart';
import '../cache/hive_cache_manager.dart';
import '../network/connectivity_service.dart';

/// Global provider for app configuration
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.load();
});

/// Global provider for API client
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config);
});

/// Global provider for HiveCacheManager
final hiveCacheManagerProvider = Provider<HiveCacheManager>((ref) {
  return HiveCacheManager.instance;
});

/// Global provider for ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});
