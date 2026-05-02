import 'package:flutter/foundation.dart';
import '../../domain/models/property_entity.dart';
import '../../domain/models/reservation_entity.dart';
import '../../domain/usecases/property_usecases.dart';
import '../../domain/usecases/reservation_usecases.dart';
import '../../domain/usecases/get_movements_by_reservation_usecase.dart';

class CalendarProvider extends ChangeNotifier {
  final GetPropertiesUseCase getPropertiesUseCase;
  final GetAllReservationsUseCase getAllReservationsUseCase;
  final GetMovementsByReservationUseCase getMovementsByReservationUseCase;

  CalendarProvider({
    required this.getPropertiesUseCase,
    required this.getAllReservationsUseCase,
    required this.getMovementsByReservationUseCase,
  });

  List<PropertyEntity> _properties = [];
  PropertyEntity? _selectedProperty;
  List<ReservationEntity> _reservations = [];
  final Map<String, double> _reservationNets = {};
  bool _isLoading = false;
  String? _error;

  List<PropertyEntity> get properties => _properties;
  PropertyEntity? get selectedProperty => _selectedProperty;
  List<ReservationEntity> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double getReservationNet(String reservationId) => _reservationNets[reservationId] ?? 0.0;

  Future<void> loadProperties(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final props = await getPropertiesUseCase(ownerId);
      _properties = props;
      _selectedProperty = props.isNotEmpty ? props.first : null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();

    if (_selectedProperty != null) {
      await loadReservations(_selectedProperty!.id);
    }
  }

  Future<void> loadReservations(String propertyId) async {
    try {
      final res = await getAllReservationsUseCase(propertyId);
      _reservations = res;
      _reservationNets.clear();
      notifyListeners();
      
      _loadAllNets(res);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadAllNets(List<ReservationEntity> reservations) async {
    for (final r in reservations) {
      try {
        final movements = await getMovementsByReservationUseCase(r.id);
        double income = 0;
        double expenses = 0;
        for (final m in movements) {
          if (m.movementType == 'income') {
            income += m.amount;
          } else {
            expenses += m.amount;
          }
        }
        _reservationNets[r.id] = income - expenses;
        notifyListeners();
      } catch (e) {
        debugPrint('Error cargando neto para ${r.id}: $e');
      }
    }
  }

  Future<void> selectProperty(PropertyEntity property) async {
    if (_selectedProperty?.id == property.id) return;
    _selectedProperty = property;
    notifyListeners();
    await loadReservations(property.id);
  }

  /// Devuelve la reserva activa en un día dado, o null.
  ReservationEntity? getReservationForDay(DateTime day) {
    final dayDate = DateTime(day.year, day.month, day.day);
    try {
      return _reservations.firstWhere((r) {
        final start = DateTime(
            r.stay.checkIn.year, r.stay.checkIn.month, r.stay.checkIn.day);
        final end = DateTime(r.stay.checkOut.year, r.stay.checkOut.month,
            r.stay.checkOut.day);
        return !dayDate.isBefore(start) && dayDate.isBefore(end);
      });
    } catch (_) {
      return null;
    }
  }
}
