import 'package:skybnb/domain/models/reservation_entity.dart';
import 'package:skybnb/domain/models/financial_movement_entity.dart';
import 'package:skybnb/core/constants/app_constants.dart';

/// Resultado de negocio calculado: liquidación mensual de una propiedad.
/// No es una colección MongoDB — es un agregado calculado por el use case.
class MonthlyStatementResult {
  final String propertyId;
  final String periodMonth;
  final List<ReservationEntity> reservations;
  final List<FinancialMovementEntity> expenses;

  // Calculados
  final double totalGross;
  final double platformFee3Pct;
  final double baseAfterPlatform;
  final double totalExpenses;
  final double baseAfterExpenses;
  final double skybnbFee15Pct;
  final double igv18PctOnSkybnb;
  final double netToOwner;

  const MonthlyStatementResult({
    required this.propertyId,
    required this.periodMonth,
    required this.reservations,
    required this.expenses,
    required this.totalGross,
    required this.platformFee3Pct,
    required this.baseAfterPlatform,
    required this.totalExpenses,
    required this.baseAfterExpenses,
    required this.skybnbFee15Pct,
    required this.igv18PctOnSkybnb,
    required this.netToOwner,
  });

  int get totalNights =>
      reservations.fold(0, (sum, r) => sum + r.stay.nights);

  String get formattedPeriod {
    final parts = periodMonth.split('-');
    if (parts.length != 2) return periodMonth;
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    final month = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) return periodMonth;
    return '${months[month - 1]} ${parts[0]}';
  }

  /// Factory: construye el resultado calculando todas las métricas.
  factory MonthlyStatementResult.calculate({
    required String propertyId,
    required String periodMonth,
    required List<ReservationEntity> reservations,
    required List<FinancialMovementEntity> expenses,
  }) {
    final totalGross = reservations.fold(
      0.0,
      (sum, r) => sum + r.pricing.grossAmount,
    );
    final platformFee3Pct = totalGross * AppConstants.platformFeeRate;
    final baseAfterPlatform = totalGross - platformFee3Pct;

    final totalExpenses = expenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final baseAfterExpenses = baseAfterPlatform - totalExpenses;
    final skybnbFee15Pct = baseAfterExpenses * AppConstants.skybnbFeeRate;
    final igv18PctOnSkybnb = skybnbFee15Pct * AppConstants.igvRate;
    final netToOwner = baseAfterExpenses - skybnbFee15Pct - igv18PctOnSkybnb;

    return MonthlyStatementResult(
      propertyId: propertyId,
      periodMonth: periodMonth,
      reservations: reservations,
      expenses: expenses,
      totalGross: totalGross,
      platformFee3Pct: platformFee3Pct,
      baseAfterPlatform: baseAfterPlatform,
      totalExpenses: totalExpenses,
      baseAfterExpenses: baseAfterExpenses,
      skybnbFee15Pct: skybnbFee15Pct,
      igv18PctOnSkybnb: igv18PctOnSkybnb,
      netToOwner: netToOwner,
    );
  }
}
