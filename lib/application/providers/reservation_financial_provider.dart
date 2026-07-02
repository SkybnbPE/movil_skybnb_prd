import 'package:flutter/foundation.dart';
import '../../domain/models/financial_movement_entity.dart';
import '../../domain/usecases/get_movements_by_reservation_usecase.dart';
import '../../core/utils/financial_category_normalizer.dart';
import '../../core/errors/exception_mapper.dart';

/// Resultado agrupado de movimientos financieros para una reserva.
class FinancialGroupedData {
  final Map<String, double> grouped;
  final double totalIncome;
  final double totalExpenses;

  const FinancialGroupedData({
    required this.grouped,
    required this.totalIncome,
    required this.totalExpenses,
  });

  double get net => totalIncome - totalExpenses;
}

/// Provider que gestiona la carga y agrupación de movimientos financieros
/// de una reserva específica.
class ReservationFinancialProvider extends ChangeNotifier {
  final GetMovementsByReservationUseCase getMovementsByReservationUseCase;

  ReservationFinancialProvider({
    required this.getMovementsByReservationUseCase,
  });

  FinancialGroupedData? _data;
  bool _isLoading = false;
  String? _error;

  FinancialGroupedData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMovements(String reservationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final movements = await getMovementsByReservationUseCase(reservationId);
      _data = _groupMovements(movements);
    } on Exception catch (e) {
      _error = ExceptionMapper.mapToFailure(e).message;
    }

    _isLoading = false;
    notifyListeners();
  }

  FinancialGroupedData _groupMovements(List<FinancialMovementEntity> movements) {
    final grouped = <String, double>{
      'rent': 0,
      'airbnb_fee': 0,
      'cleaning': 0,
      'management_fee': 0,
      'igv': 0,
    };

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final m in movements) {
      final normalized = FinancialCategoryNormalizer.normalize(m.category);
      if (normalized != null && grouped.containsKey(normalized)) {
        grouped[normalized] = (grouped[normalized] ?? 0) + m.amount;
      }

      if (m.movementType == 'income') {
        totalIncome += m.amount;
      } else {
        totalExpenses += m.amount;
      }
    }

    return FinancialGroupedData(
      grouped: grouped,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
    );
  }
}
