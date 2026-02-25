import 'package:equatable/equatable.dart';

class GenerateOTPRequest extends Equatable {
  const GenerateOTPRequest({
    required this.email,
    this.type = 1,
  });

  final String email;
  final int type;

  Map<String, dynamic> toJson() {
    return {'email': email, 'type': type};
  }

  @override
  List<Object?> get props => [email, type];
}

class RegisterOTPRequest extends Equatable {
  const RegisterOTPRequest({
    required this.mobile,
    this.roleId = 5, // Owner
  });

  final String mobile;
  final int roleId;

  Map<String, dynamic> toJson() {
    return {'mobile': mobile, 'roleId': roleId};
  }

  @override
  List<Object?> get props => [mobile, roleId];
}

class VerifyOTPRequest extends Equatable {
  const VerifyOTPRequest({
    required this.email,
    required this.otp,
    this.type = 1,
  });

  final String email;
  final String otp;
  final int type;

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'type': type};
  }

  @override
  List<Object?> get props => [email, otp, type];
}

class OTPResponse extends Equatable {
  const OTPResponse({
    required this.success,
    this.message,
    this.responseCode,
    this.token,
  });

  final bool success;
  final String? message;
  final String? responseCode;
  final String? token;

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    final responseCode = json['response_code'] as String?;
    final obj = json['obj'];
    final isSuccess = responseCode == '200';
    final message = obj?.toString();

    return OTPResponse(
      success: isSuccess,
      message: message,
      responseCode: responseCode,
      token: json['token'] as String?,
    );
  }

  @override
  List<Object?> get props => [success, message, responseCode, token];
}
