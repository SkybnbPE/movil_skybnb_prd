import 'value_objects/stay.dart';
import 'value_objects/guest_info.dart';
import 'value_objects/pricing.dart';
import 'value_objects/payment_info.dart';

/// Entidad de dominio: Reserva.
/// Alineado al schema MongoDB: Reservations Collection.
class ReservationEntity {
  final String id;           // _id
  final String propertyId;
  final String source;       // airbnb | booking | direct
  final String status;       // pending | confirmed | cancelled | completed
  final Stay stay;
  final List<GuestInfo> guests;
  final ReservationPricing pricing;
  final PaymentInfo? payment;
  final String? notes;

  const ReservationEntity({
    required this.id,
    required this.propertyId,
    required this.source,
    required this.status,
    required this.stay,
    required this.guests,
    required this.pricing,
    this.payment,
    this.notes,
  });

  /// Huésped principal de la reserva.
  GuestInfo? get primaryGuest {
    try {
      return guests.firstWhere((g) => g.isPrimary);
    } catch (_) {
      return guests.isNotEmpty ? guests.first : null;
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';

  @override
  bool operator ==(Object other) =>
      other is ReservationEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
