import 'package:skybnb/domain/models/financial_movement_entity.dart';

/// Contrato de acceso a movimientos financieros.
abstract class FinancialMovementRepository {
  /// Obtiene los movimientos de una propiedad para un periodo (YYYY-MM).
  Future<List<FinancialMovementEntity>> getMovementsByPeriod(
    String propertyId,
    String periodMonth,
  );

  /// Obtiene los movimientos financieros asociados a una reserva.
  Future<List<FinancialMovementEntity>> getMovementsByReservation(
    String reservationId,
  );
}
