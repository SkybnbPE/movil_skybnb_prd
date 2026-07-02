import 'package:skybnb/domain/models/property_entity.dart';

/// Contrato de acceso a propiedades.
abstract class PropertyRepository {
  /// Obtiene todas las propiedades activas de un propietario.
  Future<List<PropertyEntity>> getPropertiesByOwner(String ownerId);

  /// Obtiene la lista de periodos (YYYY-MM) que tienen datos para una propiedad.
  Future<List<String>> getAvailablePeriods(String propertyId);
}
