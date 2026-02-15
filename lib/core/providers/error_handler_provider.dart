import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import '../utils/snackbar_utils.dart';

/// Global error state for the application
class AppError {
  const AppError({
    required this.message,
    this.error,
    this.stackTrace,
    this.timestamp,
  });

  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime? timestamp;
}

/// Error handler notifier using Notifier with Riverpod 3.x
class ErrorHandlerNotifier extends Notifier<AppError?> {
  @override
  AppError? build() => null;

  /// Report an error globally
  void reportError(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.error(message, error, stackTrace, 'ErrorHandler');

    state = AppError(
      message: message,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
  }

  /// Clear the current error
  void clearError() {
    state = null;
  }

  /// Handle an async operation with automatic error reporting
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      reportError(errorMessage ?? e.toString(), e, stack);
      return null;
    }
  }
}

/// Global error handler provider
final errorHandlerProvider =
    NotifierProvider<ErrorHandlerNotifier, AppError?>(() {
  return ErrorHandlerNotifier();
});

/// Widget that listens to global errors and shows snackbars
class ErrorListener extends ConsumerWidget {
  const ErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AppError?>(errorHandlerProvider, (previous, next) {
      if (next != null && context.mounted) {
        SnackbarUtils.showError(context, next.message);
      }
    });

    return child;
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Setup error listening in initState
  void setupErrorListener() {
    ref.listenManual<AppError?>(
      errorHandlerProvider,
      (previous, next) {
        if (next != null && mounted) {
          _showErrorSnackbar(next.message);
        }
      },
      fireImmediately: false,
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ref.read(errorHandlerProvider.notifier).clearError();
            },
          ),
        ),
      );
    }
  }
}
