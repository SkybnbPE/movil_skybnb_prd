import '../../domain/models/property_entity.dart';
import '../../domain/models/value_objects/location.dart';
import '../../domain/models/value_objects/capacity.dart';
import '../../domain/models/value_objects/pricing.dart';

/// DTO alineado al schema MongoDB: Properties Collection.
class PropertyModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final Map<String, dynamic> locationJson;
  final List<String> media;
  final Map<String, dynamic> capacityJson;
  final Map<String, dynamic> pricingJson;
  final List<String> amenities;
  final String status;

  const PropertyModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.locationJson,
    required this.media,
    required this.capacityJson,
    required this.pricingJson,
    required this.amenities,
    required this.status,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['_id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      locationJson: Map<String, dynamic>.from(json['location'] as Map? ?? {}),
      media: List<String>.from(json['media'] as List? ?? []),
      capacityJson: Map<String, dynamic>.from(json['capacity'] as Map? ?? {}),
      pricingJson: Map<String, dynamic>.from(json['pricing'] as Map? ?? {}),
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'owner_id': ownerId,
        'name': name,
        'description': description,
        'location': locationJson,
        'media': media,
        'capacity': capacityJson,
        'pricing': pricingJson,
        'amenities': amenities,
        'status': status,
      };

  PropertyEntity toEntity() {
    final geo = locationJson['geo'] as Map? ?? {};
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,
      location: Location(
        address: locationJson['address'] as String? ?? '',
        district: locationJson['district'] as String? ?? '',
        city: locationJson['city'] as String? ?? '',
        country: locationJson['country'] as String? ?? '',
        lat: (geo['lat'] as num?)?.toDouble(),
        lng: (geo['lng'] as num?)?.toDouble(),
      ),
      media: media,
      capacity: Capacity(
        bedrooms: capacityJson['bedrooms'] as int? ?? 0,
        bathrooms: capacityJson['bathrooms'] as int? ?? 0,
        maxGuests: capacityJson['max_guests'] as int? ?? 0,
      ),
      pricing: PropertyPricing(
        basePrice: (pricingJson['base_price'] as num? ?? 0).toDouble(),
        currency: pricingJson['currency'] as String? ?? 'PEN',
        cleaningFee: (pricingJson['cleaning_fee'] as num? ?? 0).toDouble(),
      ),
      amenities: amenities,
      status: status,
    );
  }
}
