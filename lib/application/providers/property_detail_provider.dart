import 'package:flutter/foundation.dart';
import '../../domain/models/reservation_entity.dart';
import '../../domain/models/property_entity.dart';
import '../../domain/usecases/reservation_usecases.dart';
import '../../domain/usecases/get_movements_by_reservation_usecase.dart';
import '../../core/utils/reservation_net_calculator.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exception_mapper.dart';

class PropertyDetailProvider extends ChangeNotifier {
  final GetAllReservationsUseCase getAllReservationsUseCase;
  final GetMovementsByReservationUseCase getMovementsByReservationUseCase;

  PropertyDetailProvider({
    required this.getAllReservationsUseCase,
    required this.getMovementsByReservationUseCase,
  });

  PropertyEntity? _property;
  List<ReservationEntity> _reservations = [];
  final Map<String, double> _reservationNets = {};
  bool _isLoading = false;
  String? _error;

  // Pagination state
  int _visibleCount = AppConstants.initialPageSize;

  PropertyEntity? get property => _property;
  List<ReservationEntity> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get visibleCount => _visibleCount;
  List<ReservationEntity> get visibleReservations => _reservations.take(_visibleCount).toList();
  bool get canLoadMore => _visibleCount < _reservations.length;

  double getReservationNet(String reservationId) => _reservationNets[reservationId] ?? 0.0;

  double get totalIncome {
    return _reservationNets.values.fold(0.0, (sum, net) => sum + net);
  }

  int get totalReservations => _reservations.length;

  Future<void> loadData(PropertyEntity property) async {
    _property = property;
    _isLoading = true;
    _error = null;
    _visibleCount = AppConstants.initialPageSize;
    _reservationNets.clear();
    notifyListeners();

    try {
      final res = await getAllReservationsUseCase(property.id);
      
      // Ordenar por fecha de check-in descendente (más nueva primero)
      res.sort((a, b) => b.stay.checkIn.compareTo(a.stay.checkIn));
      
      _reservations = res;
      
      // Cargar movimientos financieros para cada reserva para calcular el neto real
      // Lo hacemos en segundo plano para no bloquear
      _loadAllNets(res);
      
    } on Exception catch (e) {
      _error = ExceptionMapper.mapToFailure(e).message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAllNets(List<ReservationEntity> reservations) async {
    for (final r in reservations) {
      try {
        final movements = await getMovementsByReservationUseCase(r.id);
        _reservationNets[r.id] = ReservationNetCalculator.calculate(movements);
        notifyListeners();
      } on Exception catch (e) {
        debugPrint('Error cargando neto para ${r.id}: ${ExceptionMapper.mapToFailure(e).message}');
      }
    }
  }

  void loadMore() {
    if (canLoadMore) {
      _visibleCount += AppConstants.pageSizeIncrement;
      notifyListeners();
    }
  }
}
