import '../../domain/models/financial_movement_entity.dart';
import '../../domain/repositories/financial_movement_repository.dart';
import '../datasources/remote/api_remote_datasource.dart';

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
}
