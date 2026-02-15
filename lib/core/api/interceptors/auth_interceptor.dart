import 'dart:async';
import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../storage/secure_storage.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._secureStorage);

  final LocalStorage _storage;
  final SecureStorage _secureStorage;

  final List<_RequestQueueItem> _requestQueue = [];
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    try {
      final token = await _secureStorage.read('auth_token');
      if (token != null && token.isNotEmpty) {
        options.headers['token'] = token;
        AppLogger.debug(
            'Added auth token to request: ${options.path}', 'AuthInterceptor',);
      }
    } catch (e) {
      AppLogger.error('Failed to read token', e, null, 'AuthInterceptor');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      AppLogger.warning(
          'Unauthorized error - attempting token refresh', 'AuthInterceptor',);

      if (_isRefreshing) {
        final completer = Completer<Response>();
        _requestQueue.add(_RequestQueueItem(err.requestOptions, completer));
        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }

      _isRefreshing = true;

      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          final options = err.requestOptions;
          options.headers['token'] = newToken;
          final response = await Dio().fetch(options);
          _processQueuedRequests(newToken);
          return handler.resolve(response);
        } else {
          _rejectQueuedRequests(err);
          return handler.next(err);
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e, null, 'AuthInterceptor');
        _rejectQueuedRequests(err);
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken =
          await _secureStorage.read(AppConstants.keyRefreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.warning('No refresh token available', 'AuthInterceptor');
        return null;
      }

      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _storage.setString(AppConstants.keyAccessToken, newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.write(
                AppConstants.keyRefreshToken, newRefreshToken,);
          }
          AppLogger.info('Token refreshed successfully', 'AuthInterceptor');
          return newAccessToken;
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Token refresh error', e, null, 'AuthInterceptor');
      await _storage.remove(AppConstants.keyAccessToken);
      await _secureStorage.delete(AppConstants.keyRefreshToken);
      return null;
    }
  }

  void _processQueuedRequests(String newToken) async {
    for (final item in _requestQueue) {
      try {
        item.options.headers['token'] = newToken;
        final response = await Dio().fetch(item.options);
        item.completer.complete(response);
      } catch (e) {
        item.completer.completeError(e);
      }
    }
    _requestQueue.clear();
  }

  void _rejectQueuedRequests(DioException error) {
    for (final item in _requestQueue) {
      item.completer.completeError(error);
    }
    _requestQueue.clear();
  }
}

class _RequestQueueItem {
  _RequestQueueItem(this.options, this.completer);

  final RequestOptions options;
  final Completer<Response> completer;
}
