import 'package:skybnb/data/datasources/remote/api_remote_datasource.dart';
import 'package:skybnb/data/models/user_model.dart';
import 'package:skybnb/domain/models/user/user_entity.dart';
import 'package:skybnb/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiRemoteDataSource _remote;

  const AuthRepositoryImpl(this._remote);

  @override
  Future<UserEntity?> login(String username, String password) async {
    final data = await _remote.login(username, password);
    
    // Si el backend retorna un token en la raíz, lo guardamos.
    final token = data['token'] as String?;
    if (token != null) {
      await _remote.setAuthToken(token);
    }
    
    // El API podría retornar { token, user } o directamente el objeto del usuario
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    
    if (userJson.isEmpty || !userJson.containsKey('id')) return null;
    
    return UserModel.fromJson(userJson).toEntity();
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    final model = await _remote.getUserProfile(userId);
    return model.toEntity();
  }

  @override
  Future<void> clearToken() async {
    await _remote.clearAuthToken();
  }

  @override
  Future<bool> hasSavedToken() => _remote.hasSavedToken();

  @override
  Future<String?> getSavedUserId() => _remote.getSavedUserId();

  @override
  Future<void> saveUserSession(String userId) => _remote.setSavedUserId(userId);

  @override
  Future<void> clearUserSession() async {
    await _remote.clearAuthToken();
  }
}
