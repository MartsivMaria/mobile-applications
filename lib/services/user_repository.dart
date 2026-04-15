import '../models/user_model.dart';

abstract class UserRepository {
  Future<void> register(UserModel user);
  Future<bool> login(String email, String password);

  Future<UserModel?> getUser();

  Future<void> logout();
}
