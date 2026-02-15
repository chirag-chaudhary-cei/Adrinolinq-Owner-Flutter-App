import 'package:equatable/equatable.dart';

enum ForgotPasswordStep {
  emailInput,
  otpVerification,
  passwordReset,
}

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.currentStep = ForgotPasswordStep.emailInput,
    this.isLoading = false,
    this.email,
    this.otp,
    this.canResendOtp = false,
    this.resendCountdown = 30,
    this.errorMessage,
  });

  final ForgotPasswordStep currentStep;
  final bool isLoading;
  final String? email;
  final String? otp;
  final bool canResendOtp;
  final int resendCountdown;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? currentStep,
    bool? isLoading,
    String? email,
    String? otp,
    bool? canResendOtp,
    int? resendCountdown,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      canResendOtp: canResendOtp ?? this.canResendOtp,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        isLoading,
        email,
        otp,
        canResendOtp,
        resendCountdown,
        errorMessage,
      ];
}
