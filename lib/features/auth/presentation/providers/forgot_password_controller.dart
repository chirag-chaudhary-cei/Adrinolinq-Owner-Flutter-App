import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/forgot_password_request.dart';
import '../../domain/forgot_password_state.dart';
import 'auth_providers.dart';

/// Forgot password controller using Riverpod Notifier
class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  Timer? _resendTimer;

  @override
  ForgotPasswordState build() {
    ref.onDispose(() {
      _resendTimer?.cancel();
    });
    return const ForgotPasswordState();
  }

  /// Send OTP to email
  Future<void> sendOtp(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = await ref.read(authRepositoryProvider.future);
      final response = await repository.forgotGenerateOTP(email);

      if (response.success) {
        state = state.copyWith(
          currentStep: ForgotPasswordStep.otpVerification,
          isLoading: false,
          email: email,
          canResendOtp: false,
          resendCountdown: 30,
        );
        _startResendCountdown();
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (!state.canResendOtp) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      canResendOtp: false,
    );

    try {
      final email = state.email;
      if (email == null || email.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Email missing. Please restart the flow.',
        );
        return;
      }

      final repository = await ref.read(authRepositoryProvider.future);
      final response = await repository.forgotGenerateOTP(email);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          resendCountdown: 30,
        );
        _startResendCountdown();
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to resend OTP',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Verify OTP
  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final email = state.email;
      if (email == null || email.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Email missing. Please restart the flow.',
        );
        return;
      }

      final repository = await ref.read(authRepositoryProvider.future);
      final response = await repository.forgotVerifyOTP(email, otp);

      if (response.success) {
        _resendTimer?.cancel();
        state = state.copyWith(
          currentStep: ForgotPasswordStep.passwordReset,
          isLoading: false,
          otp: otp,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Invalid OTP. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Reset password (calls API)
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please fill in all fields',
        );
        return false;
      }

      if (newPassword != confirmPassword) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Passwords do not match',
        );
        return false;
      }

      if (newPassword.length < 8) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must be at least 8 characters',
        );
        return false;
      }

      final email = state.email;
      final otp = state.otp;

      if (email == null || email.isEmpty || otp == null || otp.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Missing email or OTP. Please restart the flow.',
        );
        return false;
      }

      final request = ForgotPasswordRequest(
        email: email,
        otp: otp,
        password: newPassword,
      );

      final repository = await ref.read(authRepositoryProvider.future);
      final response = await repository.forgotPassword(request);

      if (response.success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to reset password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 0) {
        state = state.copyWith(
          resendCountdown: state.resendCountdown - 1,
        );
      } else {
        state = state.copyWith(canResendOtp: true);
        timer.cancel();
      }
    });
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void goToEmailStep() {
    _resendTimer?.cancel();
    state = state.copyWith(
      currentStep: ForgotPasswordStep.emailInput,
      canResendOtp: false,
      resendCountdown: 30,
    );
  }

  void goToOtpStep() {
    state = state.copyWith(
      currentStep: ForgotPasswordStep.otpVerification,
    );
  }

  void reset() {
    _resendTimer?.cancel();
    state = const ForgotPasswordState();
  }
}

/// Forgot password controller provider
final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(() {
  return ForgotPasswordController();
});
