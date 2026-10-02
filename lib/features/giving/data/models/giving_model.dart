import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GivingModel {
  final String? id;
  final double amount;
  final String category;

  final String? memberId;
  final String? memberName;
  final String? phoneNumber;

  final String? church;
  final String? churchName;
  final String? churchId;

  final String? destinationAccountId;
  final String? destinationBank;
  final String? destinationBankAccount;
  final String? destinationAccountName;

  final String status;

  final String? mpesaReceipt;
  final String? mpesaCheckoutId;
  final String? mpesaMerchantRequestId;
  final String? mpesaResponseCode;
  final String? mpesaResultDescription;

  final DateTime? transactionDate;
  final bool isRecurring;
  final DateTime? completedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GivingModel({
    this.id,
    required this.amount,
    required this.category,
    this.memberId,
    this.memberName,
    this.phoneNumber,
    this.church,
    this.churchName,
    this.churchId,
    this.destinationAccountId,
    this.destinationBank,
    this.destinationBankAccount,
    this.destinationAccountName,
    this.status = 'pending',
    this.mpesaReceipt,
    this.mpesaCheckoutId,
    this.mpesaMerchantRequestId,
    this.mpesaResponseCode,
    this.mpesaResultDescription,
    this.transactionDate,
    this.isRecurring = false,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory GivingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GivingModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),

      amount: _doubleValue(
        json['amount'],
      ),

      category:
          json['category']?.toString() ??
          'Other',

      memberId: _stringValue(
        json['memberId'],
      ),

      memberName: _stringValue(
        json['memberName'],
      ),

      phoneNumber: _stringValue(
        json['phoneNumber'],
      ),

      church: _stringValue(
        json['church'],
      ),

      churchName: _stringValue(
        json['churchName'],
      ),

      churchId: _extractId(
        json['churchId'],
      ),

      destinationAccountId:
          _extractId(
        json['destinationAccountId'],
      ),

      destinationBank:
          _stringValue(
        json['destinationBank'],
      ),

      destinationBankAccount:
          _stringValue(
        json['destinationBankAccount'],
      ),

      destinationAccountName:
          _stringValue(
        json['destinationAccountName'],
      ),

      status:
          json['status']?.toString() ??
          'pending',

      mpesaReceipt:
          _stringValue(
        json['mpesaReceipt'],
      ),

      mpesaCheckoutId:
          _stringValue(
        json['mpesaCheckoutId'],
      ),

      mpesaMerchantRequestId:
          _stringValue(
        json['mpesaMerchantRequestId'],
      ),

      mpesaResponseCode:
          _stringValue(
        json['mpesaResponseCode'],
      ),

      mpesaResultDescription:
          _stringValue(
        json['mpesaResultDescription'],
      ),

      transactionDate:
          _dateTimeValue(
        json['transactionDate'],
      ),

      isRecurring:
          json['isRecurring'] == true,

      completedAt:
          _dateTimeValue(
        json['completedAt'],
      ),

      createdAt:
          _dateTimeValue(
        json['createdAt'],
      ),

      updatedAt:
          _dateTimeValue(
        json['updatedAt'],
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'category': category,

      'memberId': memberId,
      'memberName': memberName,
      'phoneNumber': phoneNumber,

      'church': church,
      'churchName': churchName,
      'churchId': churchId,

      'destinationAccountId':
          destinationAccountId,

      'destinationBank':
          destinationBank,

      'destinationBankAccount':
          destinationBankAccount,

      'destinationAccountName':
          destinationAccountName,

      'status': status,

      'mpesaReceipt':
          mpesaReceipt,

      'mpesaCheckoutId':
          mpesaCheckoutId,

      'mpesaMerchantRequestId':
          mpesaMerchantRequestId,

      'mpesaResponseCode':
          mpesaResponseCode,

      'mpesaResultDescription':
          mpesaResultDescription,

      'transactionDate':
          transactionDate?.toIso8601String(),

      'isRecurring':
          isRecurring,

      'completedAt':
          completedAt?.toIso8601String(),

      'createdAt':
          createdAt?.toIso8601String(),

      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isCompleted {
    final value = status.toLowerCase();

    return value == 'completed' ||
        value == 'success' ||
        value == 'successful';
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isFailed {
    final value = status.toLowerCase();

    return value == 'failed' ||
        value == 'cancelled' ||
        value == 'canceled';
  }

  String get statusText {
    final value = status.toLowerCase();

    switch (value) {
      case 'completed':
      case 'success':
      case 'successful':
        return 'Completed';

      case 'pending':
        return 'Pending';

      case 'failed':
        return 'Failed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        if (status.isEmpty) {
          return 'Unknown';
        }

        return status[0].toUpperCase() +
            status.substring(1);
    }
  }

  Color get statusColor {
    final value = status.toLowerCase();

    switch (value) {
      case 'completed':
      case 'success':
      case 'successful':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'failed':
      case 'cancelled':
      case 'canceled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime? get displayDate {
    return transactionDate ??
        completedAt ??
        createdAt;
  }

  String get formattedDate {
    final date = displayDate;

    if (date == null) {
      return 'Date unavailable';
    }

    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(date.toLocal());
  }

  String get shortFormattedDate {
    final date = displayDate;

    if (date == null) {
      return 'Date unavailable';
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(date.toLocal());
  }

  // ============================================================
  // SAFE JSON HELPERS
  // ============================================================

  static String? _stringValue(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      if (value.trim().isEmpty) {
        return null;
      }

      return value;
    }

    return value.toString();
  }

  static double _doubleValue(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static DateTime? _dateTimeValue(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static String? _extractId(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      return _stringValue(
        value['_id'] ?? value['id'],
      );
    }

    if (value is Map) {
      return _stringValue(
        value['_id'] ?? value['id'],
      );
    }

    return value.toString();
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  GivingModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? memberId,
    String? memberName,
    String? phoneNumber,
    String? church,
    String? churchName,
    String? churchId,
    String? destinationAccountId,
    String? destinationBank,
    String? destinationBankAccount,
    String? destinationAccountName,
    String? status,
    String? mpesaReceipt,
    String? mpesaCheckoutId,
    String? mpesaMerchantRequestId,
    String? mpesaResponseCode,
    String? mpesaResultDescription,
    DateTime? transactionDate,
    bool? isRecurring,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GivingModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,

      memberId:
          memberId ?? this.memberId,

      memberName:
          memberName ?? this.memberName,

      phoneNumber:
          phoneNumber ?? this.phoneNumber,

      church:
          church ?? this.church,

      churchName:
          churchName ?? this.churchName,

      churchId:
          churchId ?? this.churchId,

      destinationAccountId:
          destinationAccountId ??
          this.destinationAccountId,

      destinationBank:
          destinationBank ??
          this.destinationBank,

      destinationBankAccount:
          destinationBankAccount ??
          this.destinationBankAccount,

      destinationAccountName:
          destinationAccountName ??
          this.destinationAccountName,

      status:
          status ?? this.status,

      mpesaReceipt:
          mpesaReceipt ??
          this.mpesaReceipt,

      mpesaCheckoutId:
          mpesaCheckoutId ??
          this.mpesaCheckoutId,

      mpesaMerchantRequestId:
          mpesaMerchantRequestId ??
          this.mpesaMerchantRequestId,

      mpesaResponseCode:
          mpesaResponseCode ??
          this.mpesaResponseCode,

      mpesaResultDescription:
          mpesaResultDescription ??
          this.mpesaResultDescription,

      transactionDate:
          transactionDate ??
          this.transactionDate,

      isRecurring:
          isRecurring ??
          this.isRecurring,

      completedAt:
          completedAt ??
          this.completedAt,

      createdAt:
          createdAt ??
          this.createdAt,

      updatedAt:
          updatedAt ??
          this.updatedAt,
    );
  }
}

