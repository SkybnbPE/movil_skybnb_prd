import 'package:skybnb/domain/models/user/user_entity.dart';
import 'package:skybnb/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<UserEntity?> call(String username, String password) =>
      _repository.login(username, password);
}

class GetUserProfileUseCase {
  final AuthRepository _repository;
  const GetUserProfileUseCase(this._repository);

  Future<UserEntity?> call(String userId) =>
      _repository.getUserProfile(userId);
}
