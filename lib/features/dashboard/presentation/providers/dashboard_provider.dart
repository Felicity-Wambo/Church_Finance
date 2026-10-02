import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/transaction_model.dart';
import '../../domain/use_cases/get_dashboard_data_use_case.dart';
import '../../data/models/dashboard_summary_model.dart';

class DashboardProvider extends ChangeNotifier {
  final GetDashboardDataUseCase _getDashboardDataUseCase;

  bool _isLoading = false;
  DashboardSummaryModel? _summary;
  List<FlSpot> _chartData = [];
  List<TransactionModel> _recentTransactions = [];
  String? _error;

  bool get isLoading => _isLoading;
  DashboardSummaryModel? get summary => _summary;
  List<FlSpot> get chartData => _chartData;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  String? get error => _error;

  DashboardProvider(this._getDashboardDataUseCase);

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _getDashboardDataUseCase.execute();

      _summary = data.summary;
      _chartData = data.chartData;
      _recentTransactions = data.recentTransactions;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}