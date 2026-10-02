import 'package:church_finance/core/models/transaction_model.dart';
import 'package:church_finance/features/dashboard/data/repository/dashboard_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/dashboard_data_model.dart';
import '../../data/models/dashboard_summary_model.dart';

class GetDashboardDataUseCase {
  final DashboardRepository _repository;

  GetDashboardDataUseCase(this._repository);

  Future<DashboardDataModel> execute() async {
    try {
      // Get summary
      final summary = await _repository.getSummary();

      // Get chart data
      final chartData = await _repository.getChartData();

      // Get recent transactions
      final transactions = await _repository.getRecentTransactions();

      return DashboardDataModel(
        summary: summary,
        chartData: chartData,
        recentTransactions: transactions,
      );
    } catch (e) {
      // Return default data for demo
      return DashboardDataModel(
        summary: const DashboardSummaryModel(
          totalGiving: 125000,
          monthlyTithes: 85000,
          weeklyOfferings: 25000,
          totalGivers: 45,
          balance: 250000,  // ✅ Added balance
        ),
        chartData: _getDefaultChartData(),
        recentTransactions: _getDefaultTransactions(),
      );
    }
  }

  List<FlSpot> _getDefaultChartData() {
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

  List<TransactionModel> _getDefaultTransactions() {
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