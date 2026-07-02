import 'package:skybnb/domain/models/reservation_entity.dart';
import 'package:skybnb/domain/models/value_objects/stay.dart';
import 'package:skybnb/domain/models/value_objects/guest_info.dart';
import 'package:skybnb/domain/models/value_objects/pricing.dart';
import 'package:skybnb/domain/models/value_objects/payment_info.dart';

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
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? json['property_id'] as String? ?? '',
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
        'id': id,
        'propertyId': propertyId,
        'source': source,
        'status': status,
        'stay': stayJson,
        'guests': guestsJson,
        'pricing': pricingJson,
        'payment': paymentJson,
        'notes': notes,
      };

  ReservationEntity toEntity() {
    final pJson = pricingJson;
    final sJson = stayJson;

    // Extraer noches del pricing o del stay, evitando cálculos locales erróneos (inDays bug)
    final pricingNights = (pJson['nights'] as num? ?? 0).toInt();
    final stayNights = (sJson['nights'] as num? ?? 0).toInt();
    
    int resolvedNights = pricingNights > 0 ? pricingNights : stayNights;
    
    if (resolvedNights <= 0) {
      final checkIn = DateTime.parse(sJson['checkIn'] as String? ?? sJson['check_in'] as String? ?? DateTime.now().toIso8601String());
      final checkOut = DateTime.parse(sJson['checkOut'] as String? ?? sJson['check_out'] as String? ?? DateTime.now().toIso8601String());
      resolvedNights = checkOut.difference(checkIn).inDays;
      
      // Fallback: si es el mismo día no cuenta como noche, pero si son días distintos al menos es 1 noche
      if (resolvedNights == 0 && (checkIn.year != checkOut.year || checkIn.month != checkOut.month || checkIn.day != checkOut.day)) {
        resolvedNights = 1;
      }
    }

    return ReservationEntity(
      id: id,
      propertyId: propertyId,
      source: source,
      status: status,
      stay: Stay(
        checkIn: DateTime.parse(sJson['checkIn'] as String? ?? sJson['check_in'] as String? ?? DateTime.now().toIso8601String()),
        checkOut: DateTime.parse(sJson['checkOut'] as String? ?? sJson['check_out'] as String? ?? DateTime.now().toIso8601String()),
        nights: resolvedNights,
      ),
      guests: guestsJson.map((g) => GuestInfo(
            guestId: g['id'] as String? ?? g['guest_id'] as String? ?? '',
            name: g['name'] as String? ?? '',
            profilePictureUrl: g['profilePictureUrl'] as String? ?? g['profile_picture_url'] as String?,
            isPrimary: g['isPrimary'] as bool? ?? g['is_primary'] as bool? ?? false,
          )).toList(),
      pricing: ReservationPricing(
        total: (pJson['total'] as num? ?? pJson['gross_amount'] as num? ?? 0).toDouble(),
        nightlyRate: (pJson['nightlyRate'] as num? ?? pJson['nightly_rate'] as num? ?? 0).toDouble(),
        nights: resolvedNights,
        cleaningFee: (pJson['cleaningFee'] as num? ?? pJson['cleaning_fee'] as num? ?? 0).toDouble(),
        currency: pJson['currency'] as String? ?? 'PEN',
        platformFee: (pJson['platformFee'] as num? ?? pJson['platform_fee'] as num? ?? 0).toDouble(),
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
