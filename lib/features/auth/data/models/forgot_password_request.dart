import 'package:equatable/equatable.dart';

class ForgotPasswordRequest extends Equatable {
  const ForgotPasswordRequest({
    required this.email,
    required this.otp,
    required this.password,
  });

  final String email;
  final String otp;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'password': password};
  }

  @override
  List<Object?> get props => [email, otp, password];
}
