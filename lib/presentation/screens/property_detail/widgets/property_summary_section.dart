import 'package:flutter/material.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/core/utils/currency_formatter.dart';
import 'package:skybnb/presentation/shared/section_card.dart';

class PropertySummarySection extends StatelessWidget {
  final double totalIncome;
  final int totalReservations;

  const PropertySummarySection({
    super.key,
    required this.totalIncome,
    required this.totalReservations,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.historicalSummary,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryBox(
                title: AppStrings.totalIncome,
                value: CurrencyFormatter.format(totalIncome),
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _SummaryBox(
                title: AppStrings.totalReservations,
                value: totalReservations.toString(),
                icon: Icons.book_online,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
