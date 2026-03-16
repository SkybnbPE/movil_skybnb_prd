import '../../domain/models/reservation_entity.dart';
import '../../domain/models/value_objects/stay.dart';
import '../../domain/models/value_objects/guest_info.dart';
import '../../domain/models/value_objects/pricing.dart';
import '../../domain/models/value_objects/payment_info.dart';

/// DTO alineado al schema MongoDB: Reservations Collection.
class ReservationModel {
  final String id;
  final String propertyId;
  final String source;
  final String status;
  final Map<String, dynamic> stayJson;
  final List<Map<String, dynamic>> guestsJson;
  final Map<String, dynamic> pricingJson;
  final Map<String, dynamic>? paymentJson;
  final String? notes;

  const ReservationModel({
    required this.id,
    required this.propertyId,
    required this.source,
    required this.status,
    required this.stayJson,
    required this.guestsJson,
    required this.pricingJson,
    this.paymentJson,
    this.notes,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['_id'] as String,
      propertyId: json['property_id'] as String,
      source: json['source'] as String? ?? 'direct',
      status: json['status'] as String? ?? 'pending',
      stayJson: Map<String, dynamic>.from(json['stay'] as Map? ?? {}),
      guestsJson: (json['guests'] as List? ?? [])
          .map((g) => Map<String, dynamic>.from(g as Map))
          .toList(),
      pricingJson: Map<String, dynamic>.from(json['pricing'] as Map? ?? {}),
      paymentJson: json['payment'] != null
          ? Map<String, dynamic>.from(json['payment'] as Map)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'property_id': propertyId,
        'source': source,
        'status': status,
        'stay': stayJson,
        'guests': guestsJson,
        'pricing': pricingJson,
        'payment': paymentJson,
        'notes': notes,
      };

  ReservationEntity toEntity() {
    return ReservationEntity(
      id: id,
      propertyId: propertyId,
      source: source,
      status: status,
      stay: Stay(
        checkIn: DateTime.parse(stayJson['check_in'] as String),
        checkOut: DateTime.parse(stayJson['check_out'] as String),
        nights: stayJson['nights'] as int? ?? 0,
      ),
      guests: guestsJson.map((g) => GuestInfo(
            guestId: g['guest_id'] as String? ?? '',
            name: g['name'] as String? ?? '',
            profilePictureUrl: g['profile_picture_url'] as String?,
            isPrimary: g['is_primary'] as bool? ?? false,
          )).toList(),
      pricing: ReservationPricing(
        grossAmount: (pricingJson['gross_amount'] as num? ?? 0).toDouble(),
        currency: pricingJson['currency'] as String? ?? 'PEN',
        platformFee: (pricingJson['platform_fee'] as num? ?? 0).toDouble(),
      ),
      payment: paymentJson != null ? _parsePayment(paymentJson!) : null,
      notes: notes,
    );
  }

  PaymentInfo _parsePayment(Map<String, dynamic> p) {
    final txList = (p['transactions'] as List? ?? [])
        .map((t) => Map<String, dynamic>.from(t as Map))
        .map((t) => PaymentTransaction(
              transactionId: t['transaction_id'] as String? ?? '',
              provider: t['provider'] as String? ?? '',
              amount: (t['amount'] as num? ?? 0).toDouble(),
              currency: t['currency'] as String? ?? 'PEN',
              status: t['status'] as String? ?? '',
              transactionDate: DateTime.parse(
                t['transaction_date'] as String? ?? DateTime.now().toIso8601String(),
              ),
            ))
        .toList();

    return PaymentInfo(
      paymentId: p['payment_id'] as String? ?? '',
      invoiceNumber: p['invoice_number'] as String? ?? '',
      status: p['status'] as String? ?? 'pending',
      transactions: txList,
    );
  }
}
