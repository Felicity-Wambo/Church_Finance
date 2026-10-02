import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChurchSelector extends StatelessWidget {
  final List<String> churches;
  final String selectedChurch;
  final ValueChanged<String> onChanged;

  const ChurchSelector({
    super.key,
    required this.churches,
    required this.selectedChurch,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Church',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedChurch,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                items: churches.map((church) {
                  // Get bank info for display
                  final bankInfo = _getBankInfo(church);
                  return DropdownMenuItem(
                    value: church,
                    child: Row(
                      children: [
                        Icon(Icons.church, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(church),
                              if (bankInfo != null)
                                Text(
                                  '💰 ${bankInfo['bank']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String>? _getBankInfo(String church) {
    final bankMap = {
      'Nairobi Central Church': {'bank': 'KCB Bank', 'account': '0112345678901'},
      'Kisumu Church': {'bank': 'Equity Bank', 'account': '0123456789012'},
      'Mombasa Church': {'bank': 'Cooperative Bank', 'account': '0134567890123'},
      'Eldoret Church': {'bank': 'Absa Bank', 'account': '0145678901234'},
      'Kisii Church': {'bank': ' NCBA', 'account': '055585'},
    };
    return bankMap[church];
  }
}