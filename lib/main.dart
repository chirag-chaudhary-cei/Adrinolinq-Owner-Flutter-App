import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/cache/hive_cache_manager.dart';
import 'core/network/connectivity_service.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.error('Flutter Error: ${details.exception}', details.exception,
          details.stack, 'Flutter',);
    };

    WidgetsFlutterBinding.ensureInitialized();

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    } catch (e) {
      AppLogger.warning('Could not set orientations: $e', 'System');
    }

    try {
      AppLogger.info('Initializing HiveCacheManager...', 'Init');
      await HiveCacheManager.initialize();
      AppLogger.success('HiveCacheManager initialized', 'Init');
    } catch (e, stack) {
      AppLogger.error(
          'Failed to initialize HiveCacheManager', e, stack, 'Init',);
    }

    try {
      AppLogger.info('Initializing ConnectivityService...', 'Init');
      await ConnectivityService.instance.initialize();
      AppLogger.success('ConnectivityService initialized', 'Init');
    } catch (e, stack) {
      AppLogger.error(
          'Failed to initialize ConnectivityService', e, stack, 'Init',);
    }

    try {
      AppLogger.info('Initializing LocalStorage...', 'Init');
      await LocalStorage.getInstance();
      AppLogger.success('LocalStorage initialized', 'Init');
    } catch (e, stack) {
      AppLogger.error('Failed to initialize LocalStorage', e, stack, 'Init');
    }

    runApp(
      const ProviderScope(
        child: App(),
      ),
    );
  }, (error, stack) {
    AppLogger.error('Uncaught error', error, stack, 'App');
  });
}
