import 'package:skybnb/domain/models/reservation_entity.dart';
import 'package:skybnb/domain/repositories/reservation_repository.dart';

class GetReservationsByPeriodUseCase {
  final ReservationRepository _repository;
  const GetReservationsByPeriodUseCase(this._repository);

  Future<List<ReservationEntity>> call(String propertyId, String periodMonth) =>
      _repository.getReservationsByPeriod(propertyId, periodMonth);
}

class GetAllReservationsUseCase {
  final ReservationRepository _repository;
  const GetAllReservationsUseCase(this._repository);

  /// Obtiene todas las reservas de una propiedad (vista de calendario).
  Future<List<ReservationEntity>> call(String propertyId) =>
      _repository.getAllReservations(propertyId);
}
