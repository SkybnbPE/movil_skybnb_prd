import 'package:flutter/foundation.dart';
import '../../domain/models/property_entity.dart';
import '../../domain/models/monthly_statement_result.dart';
import '../../domain/usecases/property_usecases.dart';
import '../../domain/usecases/get_monthly_statement_usecase.dart';

class PropertyProvider extends ChangeNotifier {
  final GetPropertiesUseCase getPropertiesUseCase;
  final GetAvailablePeriodsUseCase getAvailablePeriodsUseCase;
  final GetMonthlyStatementUseCase getMonthlyStatementUseCase;

  PropertyProvider({
    required this.getPropertiesUseCase,
    required this.getAvailablePeriodsUseCase,
    required this.getMonthlyStatementUseCase,
  });

  List<PropertyEntity> _properties = [];
  List<String> _availablePeriods = [];
  String? _selectedPeriod;
  Map<String, MonthlyStatementResult> _statements = {};
  bool _isLoading = false;
  String? _error;

  List<PropertyEntity> get properties => _properties;
  List<String> get availablePeriods => _availablePeriods;
  String? get selectedPeriod => _selectedPeriod;
  Map<String, MonthlyStatementResult> get statements => _statements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final props = await getPropertiesUseCase(ownerId);

      if (props.isNotEmpty) {
        final periods =
            await getAvailablePeriodsUseCase(props.first.id);
        final selected = periods.isNotEmpty ? periods.first : null;

        Map<String, MonthlyStatementResult> statementsMap = {};
        if (selected != null) {
          final futures = props.map((p) =>
              getMonthlyStatementUseCase(p.id, selected));
          final results = await Future.wait(futures);
          for (var i = 0; i < props.length; i++) {
            statementsMap[props[i].id] = results[i];
          }
        }

        _properties = props;
        _availablePeriods = periods;
        _selectedPeriod = selected;
        _statements = statementsMap;
      } else {
        _properties = [];
        _availablePeriods = [];
        _selectedPeriod = null;
        _statements = {};
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changePeriod(String newPeriod) async {
    if (newPeriod == _selectedPeriod) return;

    _selectedPeriod = newPeriod;
    _isLoading = true;
    notifyListeners();

    try {
      final futures = _properties.map((p) =>
          getMonthlyStatementUseCase(p.id, newPeriod));
      final results = await Future.wait(futures);
      final statementsMap = <String, MonthlyStatementResult>{};
      for (var i = 0; i < _properties.length; i++) {
        statementsMap[_properties[i].id] = results[i];
      }
      _statements = statementsMap;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
