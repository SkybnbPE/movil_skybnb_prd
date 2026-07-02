import 'package:flutter/foundation.dart';

/// Precio base de alquiler de una propiedad.
@immutable
class PropertyPricing {
  final double basePrice;
  final String currency;
  final double cleaningFee;

  const PropertyPricing({
    required this.basePrice,
    required this.currency,
    required this.cleaningFee,
  });

  @override
  bool operator ==(Object other) =>
      other is PropertyPricing &&
      basePrice == other.basePrice &&
      currency == other.currency &&
      cleaningFee == other.cleaningFee;

  @override
  int get hashCode => Object.hash(basePrice, currency, cleaningFee);
}

/// Pricing de una reserva (monto bruto cobrado al huésped + comisión plataforma).
@immutable
class ReservationPricing {
  final double total;
  final double nightlyRate;
  final int nights;
  final double cleaningFee;
  final String currency;
  final double platformFee;

  const ReservationPricing({
    required this.total,
    required this.nightlyRate,
    required this.nights,
    required this.cleaningFee,
    required this.currency,
    required this.platformFee,
  });

  /// Alias para total (mantenido por compatibilidad)
  double get grossAmount => total;

  @override
  bool operator ==(Object other) =>
      other is ReservationPricing &&
      total == other.total &&
      nightlyRate == other.nightlyRate &&
      nights == other.nights &&
      cleaningFee == other.cleaningFee &&
      currency == other.currency &&
      platformFee == other.platformFee;

  @override
  int get hashCode => Object.hash(
        total,
        nightlyRate,
        nights,
        cleaningFee,
        currency,
        platformFee,
      );
}
