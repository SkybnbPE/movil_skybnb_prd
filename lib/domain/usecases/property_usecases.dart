import 'package:skybnb/domain/models/property_entity.dart';
import 'package:skybnb/domain/repositories/property_repository.dart';

class GetPropertiesUseCase {
  final PropertyRepository _repository;
  const GetPropertiesUseCase(this._repository);

  Future<List<PropertyEntity>> call(String ownerId) =>
      _repository.getPropertiesByOwner(ownerId);
}

class GetAvailablePeriodsUseCase {
  final PropertyRepository _repository;
  const GetAvailablePeriodsUseCase(this._repository);

  Future<List<String>> call(String propertyId) =>
      _repository.getAvailablePeriods(propertyId);
}
