import 'package:dio/dio.dart';
import '../api_response_parser.dart';

/// API Error to be thrown when business logic fails
class ApiError implements Exception {
  const ApiError({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'ApiError: $message (code: $code)';
}

/// Unified response interceptor that normalizes API responses.
///
/// This interceptor:
/// 1. Checks for business logic success using configured keys
/// 2. Extracts the data payload from configured path
/// 3. Converts business errors to DioException for consistent handling
class UnifiedResponseInterceptor extends Interceptor {
  UnifiedResponseInterceptor(this._config);

  final ApiConfig _config;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only handle JSON responses
    if (response.data is! Map<String, dynamic>) {
      return handler.next(response);
    }

    final data = response.data as Map<String, dynamic>;

    // Check business logic success
    if (_config.isSuccess(data)) {
      // Flatten data: Repository will receive the actual payload directly
      response.data = _config.getData(data);
      handler.next(response);
    } else {
      // Convert business error to DioException so it's caught by repositories
      final message = _config.getErrorMessage(data) ?? 'Operation failed';
      final code = _config.getErrorCode(data);

      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: ApiError(message: message, code: code),
        ),
      );
    }
  }
}
