import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skybnb/application/providers/reservation_financial_provider.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/core/service_locator.dart';
import 'package:skybnb/core/utils/currency_formatter.dart';
import 'package:skybnb/domain/models/reservation_entity.dart';

class ReservationFinancialBottomSheet extends StatefulWidget {
  final ReservationEntity reservation;

  const ReservationFinancialBottomSheet({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationFinancialBottomSheet> createState() =>
      _ReservationFinancialBottomSheetState();
}

class _ReservationFinancialBottomSheetState
    extends State<ReservationFinancialBottomSheet> {
  late final ReservationFinancialProvider _financialProvider;

  @override
  void initState() {
    super.initState();
    _financialProvider = ServiceLocator.createReservationFinancialProvider();
    _financialProvider.loadMovements(widget.reservation.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _financialProvider,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.financialSummary,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reserva de ${widget.reservation.primaryGuest?.name ?? '—'}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const Divider(height: 32),
            Consumer<ReservationFinancialProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Text('Error: ${provider.error}'),
                  );
                }

                final data = provider.data;
                if (data == null || data.grouped.values.every((v) => v == 0)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                    child: Text(
                      AppStrings.noMovements,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    _FinancialRow(
                      label: AppStrings.rentLabel,
                      value: data.grouped['rent']!,
                      isIncome: true,
                    ),
                    _FinancialRow(
                      label: AppStrings.airbnbFeeLabel,
                      value: data.grouped['airbnb_fee']!,
                      isIncome: false,
                    ),
                    _FinancialRow(
                      label: AppStrings.cleaningLabel,
                      value: data.grouped['cleaning']!,
                      isIncome: false,
                    ),
                    _FinancialRow(
                      label: AppStrings.managementFeeLabel,
                      value: data.grouped['management_fee']!,
                      isIncome: false,
                    ),
                    _FinancialRow(
                      label: AppStrings.igvLabel,
                      value: data.grouped['igv']!,
                      isIncome: false,
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      const Text(
                        AppStrings.totalNet,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(data.net),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: data.net >= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isIncome;

  const _FinancialRow({
    required this.label,
    required this.value,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    if (value == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            '${isIncome ? "" : "- "}${CurrencyFormatter.format(value)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isIncome ? AppColors.textPrimary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
