import '../models/monthly_statement_result.dart';
import '../models/reservation_entity.dart';
import '../models/financial_movement_entity.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/financial_movement_repository.dart';

/// Calcula la liquidación mensual completa para una propiedad y periodo.
/// Combina reservas y movimientos financieros de tipo "expense".
class GetMonthlyStatementUseCase {
  final ReservationRepository _reservationRepository;
  final FinancialMovementRepository _movementRepository;

  const GetMonthlyStatementUseCase(
    this._reservationRepository,
    this._movementRepository,
  );

  Future<MonthlyStatementResult> call(
    String propertyId,
    String periodMonth,
  ) async {
    final results = await Future.wait([
      _reservationRepository.getReservationsByPeriod(propertyId, periodMonth),
      _movementRepository.getMovementsByPeriod(propertyId, periodMonth),
    ]);

    final reservations = results[0] as List<ReservationEntity>;
    final allMovements = results[1] as List<FinancialMovementEntity>;

    // Solo los movimientos de tipo expense alimentan el cálculo de gastos
    final expenses =
        allMovements.where((m) => m.movementType == 'expense').toList();

    return MonthlyStatementResult.calculate(
      propertyId: propertyId,
      periodMonth: periodMonth,
      reservations: reservations,
      expenses: expenses,
    );
  }
}
