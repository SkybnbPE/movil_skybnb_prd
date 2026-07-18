import 'package:skybnb/data/datasources/remote/api_remote_datasource.dart';
import 'package:skybnb/data/models/user_model.dart';
import 'package:skybnb/domain/models/user/user_entity.dart';
import 'package:skybnb/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiRemoteDataSource _remote;

  const AuthRepositoryImpl(this._remote);

  @override
  Future<UserEntity?> login(String username, String password) async {
    // El backend retorna directamente el UserResponseDto (sin token).
    final data = await _remote.login(username, password);

    if (data.isEmpty || !data.containsKey('id')) return null;

    return UserModel.fromJson(data).toEntity();
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
  Future<bool> hasSavedSession() => _remote.hasSavedSession();

  @override
  Future<String?> getSavedUserId() => _remote.getSavedUserId();

  @override
  Future<void> saveUserSession(String userId) => _remote.setSavedUserId(userId);

  @override
  Future<void> clearUserSession() async {
    await _remote.clearAuthToken();
  }
}
