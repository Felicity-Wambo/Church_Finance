import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/transaction_model.dart';
import 'dashboard_summary_model.dart';

class DashboardDataModel {
  final DashboardSummaryModel summary;
  final List<FlSpot> chartData;
  final List<TransactionModel> recentTransactions;

  const DashboardDataModel({
    required this.summary,
    required this.chartData,
    required this.recentTransactions,
  });
}