import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skybnb/application/providers/property_detail_provider.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/core/utils/currency_formatter.dart';
import 'package:skybnb/core/utils/date_formatter.dart';
import 'package:skybnb/domain/models/reservation_entity.dart';
import 'package:skybnb/presentation/screens/property_detail/widgets/reservation_financial_bottom_sheet.dart';
import 'package:skybnb/presentation/shared/section_card.dart';
import 'package:skybnb/presentation/shared/status_badge.dart';

class ReservationPaginatedListSection extends StatelessWidget {
  final List<ReservationEntity> reservations;
  final bool canLoadMore;
  final VoidCallback onLoadMore;

  const ReservationPaginatedListSection({
    super.key,
    required this.reservations,
    required this.canLoadMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.reservations,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          ...reservations.map((r) {
            final provider = context.read<PropertyDetailProvider>();
            return ReservationItemCard(
              reservation: r,
              netAmount: provider.getReservationNet(r.id),
            );
          }),
          if (canLoadMore)
            Center(
              child: TextButton.icon(
                onPressed: onLoadMore,
                  icon: const Icon(Icons.expand_more, color: AppColors.primary),
                  label: const Text(
                    AppStrings.viewMoreReservations,
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReservationItemCard extends StatelessWidget {
  final ReservationEntity reservation;
  final double netAmount;

  const ReservationItemCard({
    super.key,
    required this.reservation,
    required this.netAmount,
  });

  void _showFinancialSummary(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationFinancialBottomSheet(reservation: reservation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guest = reservation.primaryGuest;
    final checkIn = DateFormatter.toFull(reservation.stay.checkIn);
    final checkOut = DateFormatter.toFull(reservation.stay.checkOut);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showFinancialSummary(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest?.name ?? '—',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$checkIn - $checkOut',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(netAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${reservation.stay.nights} noches',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        text: reservation.status,
                        color: reservation.isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(text: reservation.source, color: AppColors.info),
                    ],
                  ),
                  const Text(
                    AppStrings.viewFinances,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
