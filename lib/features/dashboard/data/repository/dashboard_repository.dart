import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/dashboard_summary_model.dart';
import '../../../../core/models/transaction_model.dart';

class DashboardRepository {
  final ApiService _apiService;

  DashboardRepository(this._apiService);

  Future<DashboardSummaryModel> getSummary() async {
    try {
      final response = await _apiService.get(ApiEndpoints.dashboardSummary);
      return DashboardSummaryModel.fromJson(response.data);
    } catch (e) {
      // Return default data for demo
      return const DashboardSummaryModel(
        totalGiving: 125000,
        monthlyTithes: 85000,
        weeklyOfferings: 25000,
        totalGivers: 45,
        balance: 250000,
      );
    }
  }

  Future<List<FlSpot>> getChartData() async {
    try {
      final response = await _apiService.get(ApiEndpoints.dashboardChart);
      final List data = response.data['chartData'] ?? [];
      return data.map((item) => FlSpot(
        item['x'].toDouble(),
        item['y'].toDouble(),
      )).toList();
    } catch (e) {
      // Return default chart data
      return [
        const FlSpot(0, 100000),
        const FlSpot(1, 120000),
        const FlSpot(2, 90000),
        const FlSpot(3, 150000),
        const FlSpot(4, 130000),
        const FlSpot(5, 180000),
        const FlSpot(6, 200000),
      ];
    }
  }

  Future<List<TransactionModel>> getRecentTransactions() async {
    try {
      final response = await _apiService.get(ApiEndpoints.recentTransactions);
      final List data = response.data['transactions'] ?? [];
      return data.map((item) => TransactionModel.fromJson(item)).toList();
    } catch (e) {
      // Return default transactions
      return [
        TransactionModel(
          id: '1',
          type: TransactionType.income,
          category: 'Tithe',
          amount: 50000,
          date: DateTime.now().subtract(const Duration(days: 1)),
          memberName: 'John Mwangi',
          status: TransactionStatus.completed,
          description: 'Sunday tithe',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TransactionModel(
          id: '2',
          type: TransactionType.income,
          category: 'Offering',
          amount: 25000,
          date: DateTime.now().subtract(const Duration(days: 3)),
          memberName: 'Anonymous',
          status: TransactionStatus.completed,
          description: 'Sunday offering',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        TransactionModel(
          id: '3',
          type: TransactionType.income,
          category: 'Building Fund',
          amount: 10000,
          date: DateTime.now().subtract(const Duration(days: 5)),
          memberName: 'Mary Wanjiru',
          status: TransactionStatus.pending,
          description: 'Building fund contribution',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
    }
  }
}