import '../../domain/models/user/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiRemoteDataSource _remote;

  const AuthRepositoryImpl(this._remote);

  @override
  Future<UserEntity?> login(String username, String password) async {
    final data = await _remote.login(username, password);
    // El API retorna { token, user } — guardamos el token y devolvemos la entidad
    final token = data['token'] as String?;
    if (token != null) {
      _remote.setAuthToken(token);
    }
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) return null;
    return UserModel.fromJson(userJson).toEntity();
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    final model = await _remote.getUserProfile(userId);
    return model.toEntity();
  }
}

