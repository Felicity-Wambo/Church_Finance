import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? departmentId;
  final String? departmentName;
  final String? phoneNumber;
  final String? profileImage;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.phoneNumber,
    this.profileImage,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  bool get isAdmin => role == 'admin';
  bool get isTreasurer => role == 'treasurer';
  bool get isDepartmentHead => role == 'dept_head';
  bool get isMember => role == 'member';

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'phoneNumber': phoneNumber,
    'profileImage': profileImage,
    'isActive': isActive,
    'lastLogin': lastLogin?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] ?? json['id'] ?? '',
    email: json['email'] ?? '',
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    role: json['role'] ?? 'member',
    departmentId: json['departmentId'],
    departmentName: json['departmentName'],
    phoneNumber: json['phoneNumber'],
    profileImage: json['profileImage'],
    isActive: json['isActive'] ?? true,
    lastLogin: json['lastLogin'] != null 
        ? DateTime.tryParse(json['lastLogin'])
        : null,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  @override
  List<Object?> get props => [
    id, email, firstName, lastName, role, 
    departmentId, phoneNumber, isActive
  ];
}