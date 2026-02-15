import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ 🌐 API: ${options.method} ${options.baseUrl}${options.path}');
      print('├─────────────────────────────────────────────────────────────');
      if (options.headers.isNotEmpty) {
        print('│ 📋 Headers:');
        options.headers.forEach((key, value) {
          print('│   $key: $value');
        });
        print('├─────────────────────────────────────────────────────────────');
      }
      if (options.data != null) {
        print('│ 📤 Payload:');
        try {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(options.data);
          prettyJson.split('\n').forEach((line) => print('│   $line'));
        } catch (e) {
          print('│   ${options.data}');
        }
        print('├─────────────────────────────────────────────────────────────');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final printResponse =
          response.requestOptions.extra['printResponse'] ?? true;
      print('│ ✅ Response: ${response.statusCode}');
      print('├─────────────────────────────────────────────────────────────');
      if (printResponse && response.data != null) {
        print('│ 📥 Data:');
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response.data);
          prettyJson.split('\n').forEach((line) => print('│   $line'));
        } catch (e) {
          print('│   ${response.data}');
        }
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('│ ❌ Error: ${err.type}');
      print('│ 💬 Message: ${err.message}');
      if (err.response != null) {
        print('│ 📊 Status Code: ${err.response?.statusCode}');
        if (err.response?.data != null) {
          print('│ 📥 Error Data:');
          try {
            final prettyJson =
                const JsonEncoder.withIndent('  ').convert(err.response!.data);
            prettyJson.split('\n').forEach((line) => print('│   $line'));
          } catch (e) {
            print('│   ${err.response?.data}');
          }
        }
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }
}
