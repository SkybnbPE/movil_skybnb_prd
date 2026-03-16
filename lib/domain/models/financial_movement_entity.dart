/// Entidad de dominio: Movimiento financiero.
/// Alineado al schema MongoDB: FinancialMovements Collection.
/// `date` y `periodMonth` tienen valor de negocio directo para liquidaciones mensuales.
class FinancialMovementEntity {
  final String id;           // _id
  final String propertyId;
  final String? reservationId;
  final String movementType; // reservation_revenue | expense | commission | tax | payout
  final String category;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;       // fecha de ocurrencia del movimiento (negocio)
  final String periodMonth;  // "YYYY-MM" para agrupación de liquidaciones

  const FinancialMovementEntity({
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

  bool get isRevenue => movementType == 'reservation_revenue';
  bool get isExpense => movementType == 'expense';
  bool get isPayout => movementType == 'payout';

  @override
  bool operator ==(Object other) =>
      other is FinancialMovementEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
