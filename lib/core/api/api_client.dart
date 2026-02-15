import 'package:adrinolinq_owner/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  ApiClient(this.config) {
    _initializeDio();
  }

  final AppConfig config;
  late final Dio dio;

  void _initializeDio() {
    try {
      dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
          receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
          sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors in order (LocalStorage should already be initialized in main.dart)
      dio.interceptors.addAll([
        AuthInterceptor(LocalStorage.instance, SecureStorage.instance),
        RetryInterceptor(),
        LoggerInterceptor(),
      ]);
    } catch (e) {
      // If interceptors fail to initialize, create basic Dio without them
      dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
          receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
          sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      if (kDebugMode) {
        print('ApiClient initialization warning: $e');
      }
    }
  }

  /// Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Get base URL for constructing image URLs
  String get baseUrl => config.apiBaseUrl;
}
