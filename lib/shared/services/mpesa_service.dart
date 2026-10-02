import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class MpesaService {
  final Dio _dio;

  MpesaService(this._dio);

  /// Initiate M-Pesa STK Push payment
  Future<MpesaResponse> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.mpesaStkPush,
        data: {
          'phoneNumber': phoneNumber,
          'amount': amount,
          'accountReference': accountReference,
          'transactionDesc': transactionDesc,
        },
      );

      return MpesaResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('M-Pesa payment failed: $e');
    }
  }

  /// Check transaction status
  Future<bool> checkTransactionStatus(String transactionId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.mpesaStatus}/$transactionId',
      );
      return response.data['status'] == 'completed';
    } catch (e) {
      return false;
    }
  }
}

/// M-Pesa Response Model
class MpesaResponse {
  final String checkoutRequestId;
  final String responseCode;
  final String responseDescription;
  final String? customerMessage;
  final String? merchantRequestId;

  MpesaResponse({
    required this.checkoutRequestId,
    required this.responseCode,
    required this.responseDescription,
    this.customerMessage,
    this.merchantRequestId,
  });

  factory MpesaResponse.fromJson(Map<String, dynamic> json) {
    return MpesaResponse(
      checkoutRequestId: json['CheckoutRequestID'] ?? json['checkoutRequestId'] ?? '',
      responseCode: json['ResponseCode'] ?? json['responseCode'] ?? '',
      responseDescription: json['ResponseDescription'] ?? json['responseDescription'] ?? '',
      customerMessage: json['CustomerMessage'] ?? json['customerMessage'],
      merchantRequestId: json['MerchantRequestID'] ?? json['merchantRequestId'],
    );
  }

  bool get isSuccess => responseCode == '0';

  Map<String, dynamic> toJson() => {
    'checkoutRequestId': checkoutRequestId,
    'responseCode': responseCode,
    'responseDescription': responseDescription,
    'customerMessage': customerMessage,
    'merchantRequestId': merchantRequestId,
  };
}