import 'package:flutter/foundation.dart';
import '../../domain/models/property_entity.dart';
import '../../domain/models/reservation_entity.dart';
import '../../domain/usecases/property_usecases.dart';
import '../../domain/usecases/reservation_usecases.dart';

class PropertyProvider extends ChangeNotifier {
  final GetPropertiesUseCase getPropertiesUseCase;

  PropertyProvider({
    required this.getPropertiesUseCase,
  });

  List<PropertyEntity> _properties = [];
  bool _isLoading = false;
  String? _error;

  List<PropertyEntity> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final props = await getPropertiesUseCase(ownerId);
      _properties = props;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
