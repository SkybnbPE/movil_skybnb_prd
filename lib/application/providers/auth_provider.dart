import 'package:flutter/foundation.dart';
import 'package:skybnb/core/errors/exception_mapper.dart';
import 'package:skybnb/domain/models/user/user_entity.dart';
import 'package:skybnb/domain/repositories/auth_repository.dart';
import 'package:skybnb/domain/usecases/auth_usecases.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final AuthRepository _authRepository;

  AuthProvider({
    required this.loginUseCase,
    required this.getUserProfileUseCase,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

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
    } on Exception catch (e) {
      _error = ExceptionMapper.mapToFailure(e).message;
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
    } on Exception catch (e) {
      debugPrint('Error cargando perfil: ${ExceptionMapper.mapToFailure(e).message}');
    }
  }

  Future<void> logout() async {
    await _authRepository.clearToken();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final hasToken = await _authRepository.hasSavedToken();
    if (!hasToken) return false;

    final userId = await _authRepository.getSavedUserId();
    if (userId == null) return false;

    try {
      final user = await _authRepository.getUserProfile(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      await _authRepository.clearUserSession();
      return false;
    } on Exception catch (_) {
      await _authRepository.clearUserSession();
      return false;
    }
  }

  Future<void> saveUserSession(String userId) =>
      _authRepository.saveUserSession(userId);

  Future<void> clearUserSession() => _authRepository.clearUserSession();
}
