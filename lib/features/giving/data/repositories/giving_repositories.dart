import 'package:church_finance/shared/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/giving_model.dart';

class GivingRepository {
  final ApiService _apiService;

  GivingRepository(this._apiService);

  // ============================================================
  // PROCESS GIVING
  // ============================================================

  Future<GivingModel> processGiving({
    required double amount,
    required String category,
    String? memberName,
    String? phoneNumber,
    String? church,
    bool isRecurring = false,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.givingProcess,
      data: {
        'amount': amount,
        'category': category,
        if (memberName != null) 'memberName': memberName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (church != null) 'church': church,
        'isRecurring': isRecurring,
      },
    );

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to process giving',
      );
    }

    if (data['giving'] == null) {
      throw Exception(
        'Giving information was not returned by the server.',
      );
    }

    return GivingModel.fromJson(
      Map<String, dynamic>.from(data['giving']),
    );
  }

  // ============================================================
  // GET GIVING HISTORY
  // ============================================================

  Future<List<GivingModel>> getGivingHistory() async {
    final response = await _apiService.get(
      ApiEndpoints.givingHistory,
    );

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to load giving history',
      );
    }

    final List<dynamic> history =
        data['history'] ?? [];

    return history
        .map(
          (item) => GivingModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // CHECK M-PESA STATUS
  // ============================================================

  Future<GivingModel?> checkMpesaStatus(
    String checkoutRequestId,
  ) async {
    if (checkoutRequestId.trim().isEmpty) {
      throw Exception(
        'Checkout request ID is required.',
      );
    }

    final path =
        '${ApiEndpoints.mpesaStatus}/${Uri.encodeComponent(checkoutRequestId)}';

    final response = await _apiService.get(path);

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to check M-Pesa status',
      );
    }

    if (data['giving'] == null) {
      return null;
    }

    return GivingModel.fromJson(
      Map<String, dynamic>.from(data['giving']),
    );
  }
}
