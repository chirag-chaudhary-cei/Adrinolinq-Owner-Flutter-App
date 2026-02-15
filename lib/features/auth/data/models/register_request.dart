import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
    required this.otp,
    this.roleId = 5, // Default roleId for owner registration
  });

  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;
  final String otp;
  final int roleId;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'otp': otp,
      'roleId': roleId,
    };
  }

  @override
  List<Object?> get props =>
      [firstName, lastName, email, mobile, password, otp, roleId];
}
