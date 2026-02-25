import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/otp_models.dart';
import '../models/register_request.dart';

class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localStorage = localStorage,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;
  HiveCacheManager get _cache => HiveCacheManager.instance;

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(username: email, password: password);
    final response = await _remoteDataSource.login(request);

    // Check roleTypeIds from login header - '5' must be present (may be comma-separated e.g. '4,3,5')
    final ownerRoleIds =
        (response.roleTypeIds ?? '').split(',').map((e) => e.trim()).toList();
    if (!ownerRoleIds.contains('5')) {
      throw Exception('No Access Allowed');
    }

    await _secureStorage.write('auth_token', response.token);
    await _cache.saveAuthToken(response.token);
    await _cache.saveLoginState(true);
    await _localStorage.setBool(AppConstants.keyIsLoggedIn, true);
    await _localStorage.setString(
      AppConstants.keyRoleTypeIds,
      response.roleTypeIds ?? '',
    );

    if (response.email != null) {
      await _localStorage.setString('user_email', response.email!);
    }
    if (response.userId != null) {
      await _localStorage.setString('user_id', response.userId!);
      final userId = int.tryParse(response.userId!);
      if (userId != null) {
        await _cache.saveUserId(userId);
      }
    }
    if (response.firstName != null) {
      await _localStorage.setString('user_first_name', response.firstName!);
    }
    if (response.lastName != null) {
      await _localStorage.setString('user_last_name', response.lastName!);
    }

    return response;
  }

  Future<OTPResponse> registerOTP(String mobile) async {
    final request = RegisterOTPRequest(mobile: mobile);
    return _remoteDataSource.registerOTP(request);
  }

  Future<OTPResponse> register(RegisterRequest request) async {
    final response = await _remoteDataSource.register(request);

    if (response.success &&
        response.token != null &&
        response.token!.isNotEmpty) {
      // Check roleTypeIds if the API returned them (same as login)
      // If absent, skip the check — user just registered with roleId:5
      if (response.roleTypeIds != null && response.roleTypeIds!.isNotEmpty) {
        final ownerRoleIds =
            response.roleTypeIds!.split(',').map((e) => e.trim()).toList();
        if (!ownerRoleIds.contains('5')) {
          throw Exception('No Access Allowed');
        }
      }

      // Save token (same as login)
      await _secureStorage.write('auth_token', response.token!);
      await _cache.saveAuthToken(response.token!);
      await _cache.saveLoginState(true);
      await _localStorage.setBool(AppConstants.keyIsLoggedIn, true);
      await _localStorage.setString(
        AppConstants.keyRoleTypeIds,
        response.roleTypeIds ?? '5',
      );

      // Save user data from the registration request
      await _localStorage.setString('user_first_name', request.firstName);
      await _localStorage.setString('user_last_name', request.lastName);
      await _localStorage.setString('user_mobile', request.mobile);
    }

    return response;
  }

  Future<void> logout() async {
    await _cache.clearAll();
    await _secureStorage.delete('auth_token');
    await _localStorage.setBool(AppConstants.keyIsLoggedIn, false);
    await _localStorage.setBool(AppConstants.keyProfileSaved, false);
    await _localStorage.remove('user_email');
    await _localStorage.remove('user_id');
    await _localStorage.remove('user_first_name');
    await _localStorage.remove('user_last_name');
    await _localStorage.remove('user_mobile');
    await _localStorage.remove(AppConstants.keyRoleTypeIds);
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read('auth_token');
    if (token != null && token.isNotEmpty) return true;

    final cachedToken = _cache.getAuthToken();
    if (cachedToken != null && cachedToken.isNotEmpty) {
      return _cache.isLoggedIn();
    }

    return false;
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read('auth_token');
    if (token != null && token.isNotEmpty) return token;
    return _cache.getAuthToken();
  }

  int? getCachedUserId() {
    return _cache.getUserId();
  }

  Future<OTPResponse> forgotGenerateOTP(String email) async {
    final request = GenerateOTPRequest(email: email);
    return _remoteDataSource.forgotGenerateOTP(request);
  }

  Future<OTPResponse> forgotVerifyOTP(String email, String otp) async {
    final request = VerifyOTPRequest(email: email, otp: otp);
    return _remoteDataSource.forgotVerifyOTP(request);
  }

  Future<OTPResponse> forgotPassword(ForgotPasswordRequest request) async {
    return _remoteDataSource.forgotPassword(request);
  }
}
