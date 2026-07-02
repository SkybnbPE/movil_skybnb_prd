import 'package:skybnb/domain/models/reservation_entity.dart';
import 'package:skybnb/domain/repositories/reservation_repository.dart';
import 'package:skybnb/data/datasources/remote/api_remote_datasource.dart';

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

  @override
  Future<ReservationEntity> getReservationDetail(String reservationId) async {
    final model = await _remote.getReservationById(reservationId);
    return model.toEntity();
  }
}
