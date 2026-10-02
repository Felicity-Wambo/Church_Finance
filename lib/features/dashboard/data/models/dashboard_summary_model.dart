class DashboardSummaryModel {
  final double totalGiving;
  final double monthlyTithes;
  final double weeklyOfferings;
  final double totalGivers;
  final double balance;  // ✅ Add balance as a proper field

  const DashboardSummaryModel({
    required this.totalGiving,
    required this.monthlyTithes,
    required this.weeklyOfferings,
    required this.totalGivers,
    this.balance = 0,  // ✅ Default value
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalGiving: (json['totalGiving'] ?? 0).toDouble(),
      monthlyTithes: (json['monthlyTithes'] ?? 0).toDouble(),
      weeklyOfferings: (json['weeklyOfferings'] ?? 0).toDouble(),
      totalGivers: (json['totalGivers'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),  // ✅ Properly parse balance
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGiving': totalGiving,
    'monthlyTithes': monthlyTithes,
    'weeklyOfferings': weeklyOfferings,
    'totalGivers': totalGivers,
    'balance': balance,  // ✅ Include balance in JSON
  };
}