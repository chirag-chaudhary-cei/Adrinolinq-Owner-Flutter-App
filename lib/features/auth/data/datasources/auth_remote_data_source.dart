import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/otp_models.dart';
import '../models/register_request.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  void _validateResponse(Response response, String fallbackError) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $fallbackError');
    }

    if (response.data is Map<String, dynamic>) {
      final responseCode = response.data['response_code'] as String?;
      if (responseCode != null && responseCode != '200') {
        final errorMessage =
            _extractErrorMessage(response.data['obj'], fallbackError);
        throw Exception(errorMessage);
      }
    }
  }

  String _extractErrorMessage(dynamic obj, String fallback) {
    if (obj == null) return fallback;
    if (obj is String) return obj;
    if (obj is Map<String, dynamic>) {
      return obj['message']?.toString() ?? fallback;
    }
    return fallback;
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return _extractErrorMessage(data['obj'], e.message ?? 'Request failed');
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Please check your internet.';
      default:
        return e.message ?? 'Request failed';
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response =
          await _apiClient.post(ApiEndpoints.login, data: request.toJson());
      _validateResponse(response, 'Login failed');

      final String? token = response.headers.value('token');

      // Extract roletypeids from response headers
      final String? roleTypeIds = response.headers.value('roletypeids');

      final responseData =
          Map<String, dynamic>.from(response.data as Map<String, dynamic>);
      if (token != null && token.isNotEmpty) {
        responseData['token'] = token;
        AppLogger.info('Token extracted from header: $token', 'AuthDataSource');
      }
      if (roleTypeIds != null && roleTypeIds.isNotEmpty) {
        responseData['roleTypeIds'] = roleTypeIds;
        AppLogger.info('Role Type IDs extracted from header: $roleTypeIds',
            'AuthDataSource');
      }

      return LoginResponse.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<OTPResponse> registerOTP(RegisterOTPRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.registerOTP,
        data: request.toJson(),
      );
      _validateResponse(response, 'Failed to generate OTP');
      return OTPResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to generate OTP: ${e.toString()}');
    }
  }

  Future<OTPResponse> register(RegisterRequest request) async {
    try {
      final response =
          await _apiClient.post(ApiEndpoints.register, data: request.toJson());
      _validateResponse(response, 'Registration failed');

      final token = response.headers.value('token');
      final responseData =
          Map<String, dynamic>.from(response.data as Map<String, dynamic>);
      if (token != null && token.isNotEmpty) {
        responseData['token'] = token;
      }

      return OTPResponse.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<OTPResponse> forgotGenerateOTP(GenerateOTPRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotGenerateOTP,
        data: request.toJson(),
      );
      _validateResponse(response, 'Failed to generate OTP');
      return OTPResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to generate OTP: ${e.toString()}');
    }
  }

  Future<OTPResponse> forgotVerifyOTP(VerifyOTPRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotVerifyOTP,
        data: request.toJson(),
      );
      _validateResponse(response, 'Failed to verify OTP');
      return OTPResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  Future<OTPResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );
      _validateResponse(response, 'Failed to reset password');
      return OTPResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
