import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to check and monitor network connectivity
class ConnectivityService {
  ConnectivityService._();

  static ConnectivityService? _instance;
  static ConnectivityService get instance {
    _instance ??= ConnectivityService._();
    return _instance!;
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasConnected = _isConnected;
      _isConnected = _hasConnection(results);

      if (wasConnected != _isConnected) {
        _connectivityController.add(_isConnected);
        if (kDebugMode) {
          print(
              '📶 [Connectivity] ${_isConnected ? "Connected" : "Disconnected"}',);
        }
      }
    });
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnected = _hasConnection(results);
      return _isConnected;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Connectivity] Error checking: $e');
      }
      return false;
    }
  }

  /// Check if any connection is available
  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet,);
  }

  /// Dispose connectivity monitoring
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
