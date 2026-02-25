import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/register_request.dart';
import '../../domain/register_state.dart';
import 'auth_providers.dart';

/// Register controller using Riverpod Notifier
class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    ref.watch(authRepositoryProvider).whenData((repo) {});
    return const RegisterState();
  }

  /// Generate OTP for registration
  Future<bool> generateOTP(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = await ref.read(authRepositoryProvider.future);
      final response = await repo.registerOTP(email);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          email: email,
          otpSent: true,
        );
        return true;
      } else {
        final errorMsg = response.message ?? 'Failed to send OTP';
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        );
        return false;
      }
    } catch (e) {
      String errorMsg = 'Failed to send OTP';
      final errorStr = e.toString();
      if (errorStr.contains('Exception:')) {
        errorMsg = errorStr.replaceAll('Exception:', '').trim();
      } else {
        errorMsg = errorStr;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  /// Complete registration with OTP
  /// Returns the server response message on success, null on failure
  Future<String?> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = await ref.read(authRepositoryProvider.future);
      final response = await repo.register(request);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          registrationComplete: true,
          otpVerified: true,
        );
        return response.message;
      } else {
        final errorMsg = response.message ?? 'Registration failed';
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        );
        return null;
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  /// Reset state
  void reset() {
    state = const RegisterState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Register controller provider
final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(() {
  return RegisterController();
});
