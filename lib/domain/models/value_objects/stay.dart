import 'package:flutter/foundation.dart';

/// Rango de estancia: check-in, check-out y duración en noches.
@immutable
class Stay {
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;

  const Stay({
    required this.checkIn,
    required this.checkOut,
    required this.nights,
  });

  @override
  bool operator ==(Object other) =>
      other is Stay &&
      checkIn == other.checkIn &&
      checkOut == other.checkOut &&
      nights == other.nights;

  @override
  int get hashCode => Object.hash(checkIn, checkOut, nights);
}
