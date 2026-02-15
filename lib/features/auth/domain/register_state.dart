import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.isLoading = false,
    this.email,
    this.errorMessage,
    this.otpSent = false,
    this.otpVerified = false,
    this.registrationComplete = false,
  });

  final bool isLoading;
  final String? email;
  final String? errorMessage;
  final bool otpSent;
  final bool otpVerified;
  final bool registrationComplete;

  RegisterState copyWith({
    bool? isLoading,
    String? email,
    String? errorMessage,
    bool? otpSent,
    bool? otpVerified,
    bool? registrationComplete,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      otpSent: otpSent ?? this.otpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      registrationComplete: registrationComplete ?? this.registrationComplete,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        email,
        errorMessage,
        otpSent,
        otpVerified,
        registrationComplete,
      ];
}
