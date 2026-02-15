import 'package:flutter/foundation.dart';

/// Professional logging utility with different log levels
class AppLogger {
  AppLogger._();

  static const String _prefix = '🚀 [Owner]';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix 🐛 $tagText $message');
    }
  }

  /// Log info messages
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix ℹ️ $tagText $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix ⚠️ $tagText $message');
    }
  }

  /// Log error messages
  static void error(String message,
      [dynamic error, StackTrace? stackTrace, String? tag,]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix ❌ $tagText $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log success messages
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix ✅ $tagText $message');
    }
  }
}
