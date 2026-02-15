import 'dart:math' as math;
import 'package:dio/dio.dart';

import '../../utils/logger.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  final Map<RequestOptions, int> _retryMap = {};

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler,) async {
    final requestOptions = err.requestOptions;
    final retryCount = _retryMap[requestOptions] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      _retryMap[requestOptions] = retryCount + 1;

      AppLogger.warning(
        'Retrying request: ${requestOptions.path} (attempt ${retryCount + 1}/$maxRetries)',
        'RetryInterceptor',
      );

      try {
        final delay = _calculateDelay(retryCount);
        await Future.delayed(delay);
        final response = await Dio().fetch(requestOptions);
        _retryMap.remove(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (retryCount + 1 >= maxRetries) {
          _retryMap.remove(requestOptions);
        }
        return handler.next(err);
      }
    }

    _retryMap.remove(requestOptions);
    return handler.next(err);
  }

  Duration _calculateDelay(int retryCount) {
    final exponentialDelay = baseDelay.inMilliseconds * math.pow(2, retryCount);
    final cappedDelay = math.min(
        exponentialDelay.toDouble(), maxDelay.inMilliseconds.toDouble(),);
    final jitter = math.Random().nextDouble() * 0.2 * cappedDelay;
    return Duration(milliseconds: (cappedDelay + jitter).toInt());
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return true;
    }
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }
    if (statusCode == 429) return true;
    return false;
  }
}
