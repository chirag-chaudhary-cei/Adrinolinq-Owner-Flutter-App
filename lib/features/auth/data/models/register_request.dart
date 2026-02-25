import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.otp,
    this.roleId = 5, // Default roleId for owner registration
  });

  final String firstName;
  final String lastName;
  final String mobile;
  final String otp;
  final int roleId;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'otp': otp,
      'roleId': roleId,
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, mobile, otp, roleId];
}
