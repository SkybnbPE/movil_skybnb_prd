/// Precio base de alquiler de una propiedad.
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
class ReservationPricing {
  final double grossAmount;
  final String currency;
  final double platformFee;

  const ReservationPricing({
    required this.grossAmount,
    required this.currency,
    required this.platformFee,
  });

  @override
  bool operator ==(Object other) =>
      other is ReservationPricing &&
      grossAmount == other.grossAmount &&
      currency == other.currency &&
      platformFee == other.platformFee;

  @override
  int get hashCode => Object.hash(grossAmount, currency, platformFee);
}
