import 'package:skybnb/domain/models/financial_movement_entity.dart';

/// DTO alineado al schema MongoDB: FinancialMovements Collection.
class FinancialMovementModel {
  final String id;
  final String propertyId;
  final String? reservationId;
  final String movementType;
  final String category;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;
  final String periodMonth;

  const FinancialMovementModel({
    required this.id,
    required this.propertyId,
    this.reservationId,
    required this.movementType,
    required this.category,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.periodMonth,
  });

  factory FinancialMovementModel.fromJson(Map<String, dynamic> json) {
    return FinancialMovementModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? json['property_id'] as String? ?? '',
      reservationId: json['reservationId'] as String? ?? json['reservation_id'] as String?,
      movementType: json['movementType'] as String? ?? json['movement_type'] as String? ?? 'expense',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PEN',
      description: json['description'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      periodMonth: json['periodMonth'] as String? ?? json['period_month'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'propertyId': propertyId,
        'reservationId': reservationId,
        'movementType': movementType,
        'category': category,
        'amount': amount,
        'currency': currency,
        'description': description,
        'date': date.toIso8601String(),
        'periodMonth': periodMonth,
      };

  FinancialMovementEntity toEntity() => FinancialMovementEntity(
        id: id,
        propertyId: propertyId,
        reservationId: reservationId,
        movementType: movementType,
        category: category,
        amount: amount,
        currency: currency,
        description: description,
        date: date,
        periodMonth: periodMonth,
      );
}
