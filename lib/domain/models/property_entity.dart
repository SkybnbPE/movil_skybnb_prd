import 'package:flutter/foundation.dart';
import 'package:skybnb/domain/models/value_objects/capacity.dart';
import 'package:skybnb/domain/models/value_objects/location.dart';
import 'package:skybnb/domain/models/value_objects/pricing.dart';

/// Entidad de dominio: Propiedad.
/// Alineado al schema MongoDB: Properties Collection.
@immutable
class PropertyEntity {
  final String id;           // _id
  final String ownerId;
  final String name;
  final String description;
  final Location location;
  final List<String> media;
  final Capacity capacity;
  final PropertyPricing pricing;
  final List<String> amenities;
  final String status;       // active | inactive

  const PropertyEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.location,
    required this.media,
    required this.capacity,
    required this.pricing,
    required this.amenities,
    required this.status,
  });

  bool get isActive => status == 'active';

  /// Primera imagen de media, o null si no hay.
  String? get coverImage => media.isNotEmpty ? media.first : null;

  @override
  bool operator ==(Object other) => other is PropertyEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
