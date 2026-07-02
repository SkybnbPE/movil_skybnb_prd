import 'package:flutter/foundation.dart';

/// Capacidad de una propiedad (dormitorios, baños, máximo de huéspedes).
@immutable
class Capacity {
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;

  const Capacity({
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
  });

  @override
  bool operator ==(Object other) =>
      other is Capacity &&
      bedrooms == other.bedrooms &&
      bathrooms == other.bathrooms &&
      maxGuests == other.maxGuests;

  @override
  int get hashCode => Object.hash(bedrooms, bathrooms, maxGuests);
}
