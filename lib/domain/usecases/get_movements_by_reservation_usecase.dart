import '../models/financial_movement_entity.dart';
import '../repositories/financial_movement_repository.dart';

class GetMovementsByReservationUseCase {
  final FinancialMovementRepository _repository;

  const GetMovementsByReservationUseCase(this._repository);

  Future<List<FinancialMovementEntity>> call(String reservationId) =>
      _repository.getMovementsByReservation(reservationId);
}
