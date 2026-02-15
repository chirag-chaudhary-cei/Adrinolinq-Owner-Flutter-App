import '../datasources/profile_remote_data_source.dart';
import '../models/change_password_models.dart';
import '../models/profile_model.dart';
import 'dart:io';

/// Profile repository - business logic layer
class ProfileRepository {
  ProfileRepository({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  /// Get user profile
  Future<UserProfile> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    return await _remoteDataSource.updateProfile(profile);
  }

  /// Change password
  Future<ChangePasswordResponse> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final request = ChangePasswordRequest(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    return await _remoteDataSource.changePassword(request);
  }

  /// Upload user profile image
  Future<String> uploadUserImage(File imageFile) async {
    return await _remoteDataSource.uploadUserImage(imageFile);
  }

  /// Get user image URL
  String getUserImageUrl(String? imageFile) {
    return _remoteDataSource.getUserImageUrl(imageFile);
  }

  /// Clear cached profile data - forces fresh fetch from API
  Future<void> clearProfileCache() async {
    return await _remoteDataSource.clearProfileCache();
  }
}
