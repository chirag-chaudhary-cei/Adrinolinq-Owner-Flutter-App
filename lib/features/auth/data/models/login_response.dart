import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  const LoginResponse({
    required this.token,
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.responseCode,
    this.message,
    this.roleTypeIds,
  });

  final String token;
  final String? userId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? responseCode;
  final String? message;
  final String? roleTypeIds;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final responseCode = json['response_code'] as String?;
    final obj = json['obj'];

    Map<String, dynamic>? userData;
    String? message;

    if (obj is Map<String, dynamic>) {
      userData = obj;
      message = userData['message'] as String?;
    } else if (obj is String) {
      message = obj;
    }

    String? userId;
    if (userData != null) {
      userId = userData['userId']?.toString() ??
          userData['user_id']?.toString() ??
          userData['id']?.toString() ??
          userData['ID']?.toString();
    }

    return LoginResponse(
      token: json['token'] as String? ?? '',
      userId: userId,
      email: userData?['email'] as String?,
      firstName: userData?['firstName'] as String?,
      lastName: userData?['lastName'] as String?,
      responseCode: responseCode,
      message: message ?? json['message'] as String?,
      roleTypeIds: json['roleTypeIds'] as String?,
    );
  }

  bool get isSuccess => responseCode == '200' && token.isNotEmpty;

  @override
  List<Object?> get props => [
        token,
        userId,
        email,
        firstName,
        lastName,
        responseCode,
        message,
        roleTypeIds,
      ];
}
