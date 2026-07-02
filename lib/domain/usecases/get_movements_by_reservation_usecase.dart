import 'package:skybnb/domain/models/financial_movement_entity.dart';
import 'package:skybnb/domain/repositories/financial_movement_repository.dart';

class GetMovementsByReservationUseCase {
  final FinancialMovementRepository _repository;

  const GetMovementsByReservationUseCase(this._repository);

  Future<List<FinancialMovementEntity>> call(String reservationId) =>
      _repository.getMovementsByReservation(reservationId);
}
