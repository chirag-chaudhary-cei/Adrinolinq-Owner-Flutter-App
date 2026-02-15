import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  const LoginRequest({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [username, password];
}
