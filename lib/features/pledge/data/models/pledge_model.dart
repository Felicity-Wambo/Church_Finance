import 'package:equatable/equatable.dart';

class PledgeModel extends Equatable {
  final String id;
  final double amount;
  final String memberId;
  final String churchId;
  final String churchName;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PledgeModel({
    required this.id,
    required this.amount,
    required this.memberId,
    required this.churchId,
    required this.churchName,
    required this.month,
    required this.year,
    required this.createdAt,
    this.updatedAt,
  });

  factory PledgeModel.fromJson(Map<String, dynamic> json) => PledgeModel(
    id: json['_id'] ?? json['id'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
    memberId: json['memberId'] ?? '',
    churchId: json['churchId'] ?? '',
    churchName: json['churchName'] ?? '',
    month: json['month'] ?? DateTime.now().month,
    year: json['year'] ?? DateTime.now().year,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'memberId': memberId,
    'churchId': churchId,
    'churchName': churchName,
    'month': month,
    'year': year,
  };

  @override
  List<Object?> get props => [id, amount, memberId, churchId, month, year];
}