import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BudgetDetailScreen extends StatelessWidget {
  final String budgetId;
  
  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Budget Details for ID: $budgetId\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}