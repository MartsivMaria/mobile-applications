import '../models/user_model.dart';
import 'local_user_repository.dart';

class AuthService {
  final LocalUserRepository _repository = LocalUserRepository();

  Future<void> register(UserModel user) async {
    await _repository.register(user);
  }

  Future<bool> login(String email, String password) async {
    return await _repository.login(email, password);
  }

  Future<bool> isLoggedIn() async {
    return await _repository.isLoggedIn();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _repository.getUser();
  }

  Future<void> logout() async {
    await _repository.logout();
  }
}
