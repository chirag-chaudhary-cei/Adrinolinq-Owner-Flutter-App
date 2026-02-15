import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity status enum
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Stream provider for real-time connectivity monitoring.
///
/// Usage:
/// ```dart
/// final status = ref.watch(connectivityStatusProvider);
/// status.when(
///   data: (status) => status == ConnectivityStatus.connected,
///   loading: () => true,
///   error: (_, __) => false,
/// );
/// ```
final connectivityStatusProvider =
    StreamProvider<ConnectivityStatus>((ref) async* {
  final connectivity = Connectivity();

  // Emit initial status
  final initial = await connectivity.checkConnectivity();
  yield _mapResultToStatus(initial);

  // Listen for changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield _mapResultToStatus(results);
  }
});

ConnectivityStatus _mapResultToStatus(List<ConnectivityResult> results) {
  if (results.contains(ConnectivityResult.none)) {
    return ConnectivityStatus.disconnected;
  }
  if (results.isEmpty) {
    return ConnectivityStatus.unknown;
  }
  return ConnectivityStatus.connected;
}

/// Simple boolean provider for convenience
final isConnectedProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider);
  return status.maybeWhen(
    data: (s) => s == ConnectivityStatus.connected,
    orElse: () => true, // Assume connected by default
  );
});

/// Helper class for connectivity utilities
class ConnectivityHelper {
  static Future<bool> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static String getConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }
}
