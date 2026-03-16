import '../../domain/models/reservation_entity.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/remote/api_remote_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ApiRemoteDataSource _remote;

  const ReservationRepositoryImpl(this._remote);

  @override
  Future<List<ReservationEntity>> getReservationsByPeriod(
    String propertyId,
    String periodMonth,
  ) async {
    final models =
        await _remote.getReservationsByPeriod(propertyId, periodMonth);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ReservationEntity>> getAllReservations(String propertyId) async {
    final models = await _remote.getAllReservations(propertyId);
    return models.map((m) => m.toEntity()).toList();
  }
}
