import '../models/user/user_entity.dart';

/// Contrato de autenticación.
/// Las implementaciones residen en data/repositories.
abstract class AuthRepository {
  /// Autentica un usuario con sus credenciales.
  /// Retorna [UserEntity] si las credenciales son válidas, null en caso contrario.
  Future<UserEntity?> login(String username, String password);

  /// Obtiene el perfil del usuario autenticado por su ID.
  Future<UserEntity?> getUserProfile(String userId);

  /// Limpia el token de autenticación almacenado.
  Future<void> clearToken();
}
