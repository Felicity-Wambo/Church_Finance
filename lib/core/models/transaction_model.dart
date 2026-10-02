import 'dart:ui';

import 'package:equatable/equatable.dart';
import '../constants/app_colors.dart';

enum TransactionType { income, expense }
enum TransactionStatus { pending, approved, rejected, completed }
enum PaymentMethod { cash, mpesa, bank, cheque }

class TransactionModel extends Equatable {
  final String id;
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String? memberId;
  final String? memberName;
  final String? departmentId;
  final String? departmentName;
  final String description;
  final TransactionStatus status;
  final PaymentMethod? paymentMethod;
  final String? receiptUrl;
  final String? approvedById;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.memberId,
    this.memberName,
    this.departmentId,
    this.departmentName,
    this.description = '',
    this.status = TransactionStatus.pending,
    this.paymentMethod,
    this.receiptUrl,
    this.approvedById,
    this.approvedByName,
    this.approvedAt,
    this.reference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedAmount => 'KSh ${amount.toStringAsFixed(2)}';
  String get formattedDate => _formatDate(date);

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool get isPending => status == TransactionStatus.pending;
  bool get isApproved => status == TransactionStatus.approved;
  bool get isRejected => status == TransactionStatus.rejected;
  bool get isCompleted => status == TransactionStatus.completed;

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.approved:
        return AppColors.success;
      case TransactionStatus.rejected:
        return AppColors.error;
      case TransactionStatus.completed:
        return AppColors.info;
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.approved:
        return 'Approved';
      case TransactionStatus.rejected:
        return 'Rejected';
      case TransactionStatus.completed:
        return 'Completed';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'memberId': memberId,
    'memberName': memberName,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'description': description,
    'status': status.name,
    'paymentMethod': paymentMethod?.name,
    'receiptUrl': receiptUrl,
    'approvedById': approvedById,
    'approvedByName': approvedByName,
    'approvedAt': approvedAt?.toIso8601String(),
    'reference': reference,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'] ?? json['_id'] ?? '',
    type: TransactionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => TransactionType.income,
    ),
    category: json['category'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    memberId: json['memberId'],
    memberName: json['memberName'],
    departmentId: json['departmentId'],
    departmentName: json['departmentName'],
    description: json['description'] ?? '',
    status: json['status'] != null
        ? TransactionStatus.values.firstWhere(
            (e) => e.name == json['status'],
            orElse: () => TransactionStatus.pending,
          )
        : TransactionStatus.pending,
    paymentMethod: json['paymentMethod'] != null
        ? PaymentMethod.values.firstWhere(
            (e) => e.name == json['paymentMethod'],
            orElse: () => PaymentMethod.cash,
          )
        : null,
    receiptUrl: json['receiptUrl'],
    approvedById: json['approvedById'],
    approvedByName: json['approvedByName'],
    approvedAt: json['approvedAt'] != null
        ? DateTime.parse(json['approvedAt'])
        : null,
    reference: json['reference'],
    notes: json['notes'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now(),
  );

  @override
  List<Object?> get props => [
    id, type, category, amount, date, status,
    description, memberId, departmentId
  ];
}