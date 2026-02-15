import 'package:flutter/foundation.dart';

/// Simple smart cache helper - no timers, just debug logging
class SmartCacheDebug {
  static void logCacheHit() {
    if (kDebugMode) {
      print('⚡ [SmartCache] Showing cached data immediately');
    }
  }

  static void logFetching() {
    if (kDebugMode) {
      print('🔄 [SmartCache] Fetching fresh data in background...');
    }
  }

  static void logNoCache() {
    if (kDebugMode) {
      print('🌐 [SmartCache] No cache, fetching from API...');
    }
  }

  static void logRefreshing() {
    if (kDebugMode) {
      print('⏳ [SmartCache] Already refreshing, skipping...');
    }
  }

  static void logDataChanged(int oldCount, int newCount) {
    if (kDebugMode) {
      print(
          '✅ [SmartCache] Data changed ($oldCount → $newCount items), UI updated',);
    }
  }

  static void logNoChange() {
    if (kDebugMode) {
      print('✅ [SmartCache] No new data, cache is up to date');
    }
  }

  static void logFailed(Object e) {
    if (kDebugMode) {
      print('⚠️ [SmartCache] Background fetch failed: $e');
    }
  }
}
