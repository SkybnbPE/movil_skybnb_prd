import '../models/reservation_entity.dart';

/// Contrato de acceso a reservas.
abstract class ReservationRepository {
  /// Obtiene las reservas de una propiedad para un periodo específico (YYYY-MM).
  Future<List<ReservationEntity>> getReservationsByPeriod(
    String propertyId,
    String periodMonth,
  );

  /// Obtiene TODAS las reservas de una propiedad (para el calendario).
  Future<List<ReservationEntity>> getAllReservations(String propertyId);
}
