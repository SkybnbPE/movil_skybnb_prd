import 'package:flutter/foundation.dart';
import '../../domain/models/user/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.getUserProfileUseCase,
  });

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await loginUseCase(username, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile(String userId) async {
    try {
      final user = await getUserProfileUseCase(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (_) {}
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
