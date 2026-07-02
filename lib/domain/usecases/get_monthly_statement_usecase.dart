import 'package:skybnb/domain/models/monthly_statement_result.dart';
import 'package:skybnb/domain/repositories/financial_movement_repository.dart';
import 'package:skybnb/domain/repositories/reservation_repository.dart';

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
    final reservationsFuture = _reservationRepository.getReservationsByPeriod(propertyId, periodMonth);
    final movementsFuture = _movementRepository.getMovementsByPeriod(propertyId, periodMonth);

    final reservations = await reservationsFuture;
    final allMovements = await movementsFuture;

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
