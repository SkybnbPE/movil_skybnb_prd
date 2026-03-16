import '../../domain/models/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/remote/api_remote_datasource.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final ApiRemoteDataSource _remote;

  const PropertyRepositoryImpl(this._remote);

  @override
  Future<List<PropertyEntity>> getPropertiesByOwner(String ownerId) async {
    final models = await _remote.getPropertiesByOwner(ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<String>> getAvailablePeriods(String propertyId) async {
    return _remote.getAvailablePeriods(propertyId);
  }
}
