import 'package:flutter/foundation.dart';
import 'package:skybnb/core/errors/exception_mapper.dart';
import 'package:skybnb/domain/models/property_entity.dart';
import 'package:skybnb/domain/usecases/property_usecases.dart';

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
    } on Exception catch (e) {
      _error = ExceptionMapper.mapToFailure(e).message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
