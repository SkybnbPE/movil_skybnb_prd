import '../../domain/models/financial_movement_entity.dart';

/// Calcula el neto (ingreso - gastos) de una reserva a partir de sus movimientos financieros.
class ReservationNetCalculator {
  ReservationNetCalculator._();

  /// Retorna el neto de una lista de movimientos: ingresos - gastos.
  static double calculate(List<FinancialMovementEntity> movements) {
    double income = 0;
    double expenses = 0;
    for (final m in movements) {
      if (m.movementType == 'income') {
        income += m.amount;
      } else {
        expenses += m.amount;
      }
    }
    return income - expenses;
  }
}
