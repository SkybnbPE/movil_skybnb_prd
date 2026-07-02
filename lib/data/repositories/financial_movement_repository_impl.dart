import 'package:skybnb/data/datasources/remote/api_remote_datasource.dart';
import 'package:skybnb/domain/models/financial_movement_entity.dart';
import 'package:skybnb/domain/repositories/financial_movement_repository.dart';

class FinancialMovementRepositoryImpl implements FinancialMovementRepository {
  final ApiRemoteDataSource _remote;

  const FinancialMovementRepositoryImpl(this._remote);

  @override
  Future<List<FinancialMovementEntity>> getMovementsByPeriod(
    String propertyId,
    String periodMonth,
  ) async {
    final models =
        await _remote.getMovementsByPeriod(propertyId, periodMonth);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<FinancialMovementEntity>> getMovementsByReservation(
    String reservationId,
  ) async {
    final models = await _remote.getMovementsByReservation(reservationId);
    return models.map((m) => m.toEntity()).toList();
  }
}
