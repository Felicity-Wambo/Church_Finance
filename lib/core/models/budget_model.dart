import 'dart:ui';

import 'package:equatable/equatable.dart';
import '../constants/app_colors.dart';

class BudgetModel extends Equatable {
  final String id;
  final String departmentId;
  final String departmentName;
  final String category;
  final int year;
  final int month;
  final double allocated;
  final double actual;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const BudgetModel({
    required this.id,
    required this.departmentId,
    required this.departmentName,
    required this.category,
    required this.year,
    required this.month,
    required this.allocated,
    required this.actual,
    required this.createdAt,
    required this.updatedAt,
  });
  
  double get variance => allocated - actual;
  double get variancePercentage => allocated > 0 ? (variance / allocated) * 100 : 0;
  double get utilization => allocated > 0 ? (actual / allocated) * 100 : 0;
  
  bool get isOverBudget => actual > allocated;
  bool get isUnderBudget => actual < allocated;
  bool get isOnBudget => actual == allocated;
  
  Color get statusColor {
    if (isOverBudget) return AppColors.error;
    if (utilization > 80) return AppColors.warning;
    return AppColors.success;
  }
  
  String get statusText {
    if (isOverBudget) return '🔴 Overspent';
    if (utilization > 80) return '🟡 Warning';
    return '✅ On Track';
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'category': category,
    'year': year,
    'month': month,
    'allocated': allocated,
    'actual': actual,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    id: json['id'],
    departmentId: json['departmentId'],
    departmentName: json['departmentName'],
    category: json['category'],
    year: json['year'],
    month: json['month'],
    allocated: json['allocated'].toDouble(),
    actual: json['actual'].toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  
  @override
  List<Object?> get props => [
    id, departmentId, category, year, month, 
    allocated, actual
  ];
}