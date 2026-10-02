import 'package:flutter/material.dart';

class PledgeProvider extends ChangeNotifier {
  double _currentPledge = 0;
  bool _isLoading = false;
  String? _errorMessage;

  double get currentPledge => _currentPledge;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> setPledge({
    required double amount,
    required String churchId,
    required String churchName,
    required String memberId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate saving to backend
      await Future.delayed(const Duration(seconds: 1));
      _currentPledge = amount;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPledge(String memberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate loading from backend
      await Future.delayed(const Duration(milliseconds: 500));
      _currentPledge = 5000; // Mock value
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}