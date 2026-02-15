import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../../../core/api/api_client.dart';
import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/change_password_models.dart';
import '../models/profile_model.dart';

/// Profile remote data source - handles all profile API calls
/// Implements offline-first cache strategy using Hive
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;
  HiveCacheManager get _cache => HiveCacheManager.instance;
  ConnectivityService get _connectivity => ConnectivityService.instance;

  /// Validate API response - checks both HTTP status code and response_code
  void _validateResponse(Response response, String fallbackError) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $fallbackError');
    }

    if (response.data is Map<String, dynamic>) {
      final responseCode = response.data['response_code'] as String?;
      if (responseCode != null && responseCode != '200') {
        final errorMessage = _extractErrorMessage(
          response.data['obj'],
          fallbackError,
        );
        throw Exception(errorMessage);
      }
    }
  }

  /// Extract error message from API response
  String _extractErrorMessage(dynamic obj, String fallback) {
    if (obj == null) return fallback;
    if (obj is String) return obj;
    if (obj is Map<String, dynamic>) {
      return obj['message']?.toString() ?? fallback;
    }
    return fallback;
  }

  /// Handle Dio errors
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

  /// Get user profile
  /// Uses offline-first strategy: returns cached data immediately, refreshes in background
  Future<UserProfile> getProfile() async {
    try {
      AppLogger.info('Fetching user profile', 'ProfileDataSource');

      final response = await _apiClient.post(
        ApiEndpoints.getProfile,
        data: {},
      );

      _validateResponse(response, 'Failed to fetch profile');

      final obj = response.data['obj'];
      if (obj is Map<String, dynamic>) {
        AppLogger.success('Profile fetched successfully', 'ProfileDataSource');

        // WORKAROUND: Backend doesn't return imageFile in getProfile
        // Check if we have a cached imageFile from a previous upload
        final cachedImageFile = await _cache.get('user_uploaded_image_file');
        if (cachedImageFile != null && obj['imageFile'] == null) {
          if (kDebugMode) {
            print(
                '🖼️ [ProfileDS] Restoring cached imageFile: $cachedImageFile');
          }
          obj['imageFile'] = cachedImageFile;
        }

        // Cache the profile data for offline access
        await _cache.saveProfile(obj);

        // Also cache user ID for offline access
        if (obj['id'] != null) {
          await _cache.saveUserId(obj['id'] as int);
        }

        return UserProfile.fromJson(obj);
      } else {
        throw Exception('Invalid profile data format');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        if (kDebugMode) {
          print('📴 [ProfileDS] Network error, checking cache...');
        }
        final cachedProfile = _cache.getProfile();
        if (cachedProfile != null) {
          if (kDebugMode) {
            print('✅ [ProfileDS] Returning cached profile (offline mode)');
          }
          return UserProfile.fromJson(cachedProfile);
        }
      }
      throw Exception(_handleError(e));
    } catch (e) {
      final cachedProfile = _cache.getProfile();
      if (cachedProfile != null) {
        if (kDebugMode) {
          print('⚠️ [ProfileDS] Error occurred, returning cached profile');
        }
        return UserProfile.fromJson(cachedProfile);
      }
      throw Exception('Failed to fetch profile: ${e.toString()}');
    }
  }

  /// Get cached profile immediately (for offline-first display)
  UserProfile? getCachedProfile() {
    final cachedData = _cache.getProfile();
    if (cachedData != null) {
      return UserProfile.fromJson(cachedData);
    }
    return null;
  }

  /// Check if cached profile exists
  bool hasCachedProfile() {
    return _cache.hasProfile();
  }

  /// Clear cached profile data
  Future<void> clearProfileCache() async {
    await _cache.clearProfile();
    AppLogger.info('Profile cache cleared', 'ProfileDataSource');
  }

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    if (!_connectivity.isConnected) {
      throw Exception(
        'Internet connection required to update profile. Please check your connection and try again.',
      );
    }

    try {
      final payload = profile.toUpdateJson();

      AppLogger.info('Updating user profile', 'ProfileDataSource');
      AppLogger.debug('Payload: $payload', 'ProfileDataSource');

      final response = await _apiClient.post(
        ApiEndpoints.updateProfile,
        data: payload,
      );

      _validateResponse(response, 'Failed to update profile');

      final obj = response.data['obj'];
      if (obj is Map<String, dynamic>) {
        AppLogger.success('Profile updated successfully', 'ProfileDataSource');
        await _cache.saveProfile(obj);
        return UserProfile.fromJson(obj);
      } else {
        AppLogger.warning(
          'API did not return updated profile',
          'ProfileDataSource',
        );
        return profile;
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Change password
  Future<ChangePasswordResponse> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      AppLogger.info('Changing password', 'ProfileDataSource');

      final response = await _apiClient.post(
        ApiEndpoints.changePassword,
        data: request.toJson(),
      );

      _validateResponse(response, 'Failed to change password');

      AppLogger.success('Password changed successfully', 'ProfileDataSource');
      return ChangePasswordResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  /// Upload user profile image
  Future<String> uploadUserImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last.split('\\').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      AppLogger.info('Uploading user image: $fileName', 'ProfileDataSource');

      final response = await _apiClient.post(
        ApiEndpoints.uploadUserFile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to upload image');
      }

      if (response.data is Map<String, dynamic>) {
        final responseCode = response.data['response_code'] as String?;
        if (responseCode == '200' || responseCode == '201') {
          final obj = response.data['obj'] as String?;
          if (obj != null && obj.isNotEmpty) {
            final lastSlashIndex = obj.lastIndexOf('/');
            final extractedFileName =
                lastSlashIndex >= 0 ? obj.substring(lastSlashIndex + 1) : obj;

            // WORKAROUND: Cache the uploaded imageFile since backend doesn't return it in getProfile
            await _cache.save('user_uploaded_image_file', extractedFileName);
            if (kDebugMode) {
              print(
                  '💾 [ProfileDS] Cached uploaded imageFile: $extractedFileName');
            }

            AppLogger.success(
              'Image uploaded: $extractedFileName',
              'ProfileDataSource',
            );
            return extractedFileName;
          }
        }
        throw Exception(response.data['message'] ?? 'Failed to upload image');
      }

      throw Exception('Invalid response format');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get user image URL
  String getUserImageUrl(String? imageFile) {
    if (imageFile == null || imageFile.isEmpty) {
      return '';
    }
    return '${_apiClient.baseUrl}${ApiEndpoints.usersUploads}$imageFile';
  }
}
