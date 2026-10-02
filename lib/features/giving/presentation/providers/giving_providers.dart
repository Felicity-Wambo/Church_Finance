import 'package:flutter/material.dart';

import '../../data/models/giving_model.dart';
import '../../data/repositories/giving_repositories.dart';
import '../../domain/use_cases/get_giving_history._use_case.dart';
import '../../domain/use_cases/process_giving_use_case.dart';

class GivingProvider extends ChangeNotifier {
  final ProcessGivingUseCase _processGivingUseCase;
  final GetGivingHistoryUseCase _getGivingHistoryUseCase;
  final GivingRepository _givingRepository;

  GivingProvider({
    required ProcessGivingUseCase processGivingUseCase,
    required GetGivingHistoryUseCase getGivingHistoryUseCase,
    required GivingRepository givingRepository,
  })  : _processGivingUseCase = processGivingUseCase,
        _getGivingHistoryUseCase = getGivingHistoryUseCase,
        _givingRepository = givingRepository;

  bool _isLoading = false;
  String? _errorMessage;

  GivingModel? _lastGiving;

  List<GivingModel> _givingHistory = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  GivingModel? get lastGiving => _lastGiving;

  List<GivingModel> get givingHistory =>
      List.unmodifiable(_givingHistory);

  // ============================================================
  // PROCESS GIVING
  // ============================================================

  Future<GivingModel?> processGiving({
    required double amount,
    required String category,
    String? memberName,
    String? phoneNumber,
    String? church,
    bool isRecurring = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final giving =
          await _processGivingUseCase.execute(
        amount: amount,
        category: category,
        memberName: memberName,
        phoneNumber: phoneNumber,
        church: church,
        isRecurring: isRecurring,
      );

      _lastGiving = giving;

      _isLoading = false;
      notifyListeners();

      return giving;
    } catch (e) {
      _errorMessage = _cleanError(e);

      _isLoading = false;
      notifyListeners();

      return null;
    }
  }

  // ============================================================
  // GET HISTORY
  // ============================================================

  Future<void> loadGivingHistory() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _givingHistory =
          await _getGivingHistoryUseCase.execute();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanError(e);

      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CHECK M-PESA STATUS
  // ============================================================

  Future<GivingModel?> checkMpesaStatus(
    String checkoutRequestId,
  ) async {
    try {
      final updatedGiving =
          await _givingRepository.checkMpesaStatus(
        checkoutRequestId,
      );

      if (updatedGiving != null) {
        _lastGiving = updatedGiving;

        final index = _givingHistory.indexWhere(
          (item) => item.id == updatedGiving.id,
        );

        if (index != -1) {
          _givingHistory[index] = updatedGiving;
        }
      }

      notifyListeners();

      return updatedGiving;
    } catch (e) {
      _errorMessage = _cleanError(e);
      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // SET COMPLETED GIVING
  // ============================================================

  void setCompletedGiving(GivingModel giving) {
    _lastGiving = giving;

    final index = _givingHistory.indexWhere(
      (item) => item.id == giving.id,
    );

    if (index != -1) {
      _givingHistory[index] = giving;
    } else {
      _givingHistory.insert(0, giving);
    }

    notifyListeners();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearLastGiving() {
    _lastGiving = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}

