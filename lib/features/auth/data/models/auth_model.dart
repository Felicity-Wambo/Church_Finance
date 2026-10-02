import 'package:church_finance/features/auth/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String phoneNumber;
  final String pin;

  const LoginRequest({
    required this.phoneNumber,
    required this.pin,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'pin': pin,
  };

  @override
  List<Object?> get props => [phoneNumber, pin];
}

class RegisterRequest extends Equatable {
  final String phoneNumber;
  final String pin;
  final String confirmPin;
  final String firstName;
  final String lastName;
  final String? email;
  final String? role;

  const RegisterRequest({
    required this.phoneNumber,
    required this.pin,
    required this.confirmPin,
    required this.firstName,
    required this.lastName,
    this.email,
    this.role = 'member',
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'pin': pin,
    'confirmPin': confirmPin,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
  };

  @override
  List<Object?> get props => [
    phoneNumber, pin, confirmPin, firstName, 
    lastName, email, role
  ];
}

class AuthResponse extends Equatable {
  final String token;
  final String refreshToken;
  final UserModel user;
  final bool requiresOtp;
  final String? message;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    this.requiresOtp = false,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      requiresOtp: json['requiresOtp'] ?? false,
      message: json['message'],
    );
  }

  @override
  List<Object?> get props => [token, refreshToken, user, requiresOtp, message];
}