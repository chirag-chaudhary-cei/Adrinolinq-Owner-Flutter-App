import 'package:equatable/equatable.dart';

/// Change password request model
class ChangePasswordRequest extends Equatable {
  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

/// Change password response model
class ChangePasswordResponse extends Equatable {
  const ChangePasswordResponse({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    final responseCode = json['response_code'] as String?;
    final isSuccess = responseCode == '200';
    final message = json['obj']?.toString() ?? json['message']?.toString();

    return ChangePasswordResponse(
      success: isSuccess,
      message: message,
    );
  }

  @override
  List<Object?> get props => [success, message];
}
