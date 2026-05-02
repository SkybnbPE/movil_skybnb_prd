import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/financial_movement_entity.dart';
import '../../../../domain/models/reservation_entity.dart';

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
  late Future<List<FinancialMovementEntity>> _movementsFuture;

  @override
  void initState() {
    super.initState();
    _movementsFuture = ServiceLocator.getMovementsByReservationUseCase(
      widget.reservation.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'Resumen Financiero',
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
          FutureBuilder<List<FinancialMovementEntity>>(
            future: _movementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final movements = snapshot.data ?? [];
              if (movements.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No hay movimientos registrados.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              // Group by categories: 'rent', 'airbnb_fee', 'cleaning', 'management_fee', 'igv'
              final Map<String, double> grouped = {
                'rent': 0,
                'airbnb_fee': 0,
                'cleaning': 0,
                'management_fee': 0,
                'igv': 0,
              };

              double totalIncome = 0;
              double totalExpenses = 0;

              for (final m in movements) {
                String cat = m.category.toLowerCase().trim();
                // Normalizar variaciones de nombres de categorías
                if (cat == 'managment_fee' || cat == 'managment' || cat == 'management' || cat == 'commission' || cat == 'management_fee') {
                  cat = 'management_fee';
                }
                if (cat == 'airbnb' || cat == 'airbnbfee' || cat == 'platform_fee' || cat == 'airbnb_fee') {
                  cat = 'airbnb_fee';
                }
                if (cat == 'rent' || cat == 'accommodation' || cat == 'room_rate' || cat == 'revenue') {
                  cat = 'rent';
                }

                if (grouped.containsKey(cat)) {
                  grouped[cat] = (grouped[cat] ?? 0) + m.amount;
                }
                
                if (m.movementType == 'income') {
                  totalIncome += m.amount;
                } else {
                  totalExpenses += m.amount;
                }
              }

              final net = totalIncome - totalExpenses;

              return Column(
                children: [
                  _FinancialRow(
                    label: 'Renta (Rent)',
                    value: grouped['rent']!,
                    isIncome: true,
                  ),
                  _FinancialRow(
                    label: 'Comisión Airbnb',
                    value: grouped['airbnb_fee']!,
                    isIncome: false,
                  ),
                  _FinancialRow(
                    label: 'Limpieza (Cleaning)',
                    value: grouped['cleaning']!,
                    isIncome: false,
                  ),
                  _FinancialRow(
                    label: 'Comisión Skybnb (Management)',
                    value: grouped['management_fee']!,
                    isIncome: false,
                  ),
                  _FinancialRow(
                    label: 'IGV',
                    value: grouped['igv']!,
                    isIncome: false,
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Neto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(net),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: net >= 0 ? AppColors.success : AppColors.error,
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
