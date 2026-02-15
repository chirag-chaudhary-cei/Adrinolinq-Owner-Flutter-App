import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Result type for repository operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

/// Extension methods for Result type
extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Error() => null,
  };
  
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Error(:final failure) => failure,
  };
  
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Error(:final failure) => onError(failure),
    };
  }
}

/// Base repository class with common error handling
abstract class BaseRepository {
  BaseRepository(this.apiClient);
  
  final ApiClient apiClient;
  
  /// Execute an API call with automatic error handling
  Future<Result<T>> execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Success(result);
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } on AppException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
  
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      default:
        return ServerFailure(error.message ?? 'Unknown error');
    }
  }
  
  Failure _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final message = response?.data?['message'] ?? 'Server error';
    
    if (statusCode == 401) {
      return const UnauthorizedFailure();
    } else if (statusCode == 404) {
      return ServerFailure('Resource not found: $message');
    } else if (statusCode >= 500) {
      return ServerFailure('Server error: $message');
    } else {
      return ServerFailure(message);
    }
  }
}

