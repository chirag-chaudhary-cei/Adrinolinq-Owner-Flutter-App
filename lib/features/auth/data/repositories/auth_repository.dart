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

    await _secureStorage.write('auth_token', response.token);
    await _cache.saveAuthToken(response.token);
    await _cache.saveLoginState(true);
    await _localStorage.setBool(AppConstants.keyIsLoggedIn, true);

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

  Future<OTPResponse> registerOTP(String email) async {
    final request = GenerateOTPRequest(email: email);
    return _remoteDataSource.registerOTP(request);
  }

  Future<OTPResponse> register(RegisterRequest request) async {
    return _remoteDataSource.register(request);
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
