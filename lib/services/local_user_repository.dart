import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class LocalUserRepository implements UserRepository {
  static const _userKey = 'user';
  static const _loggedInKey = 'logged_in';

  @override
  Future<void> register(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);

    await prefs.setBool(_loggedInKey, true);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_userKey);
    if (data == null) return false;

    final json = jsonDecode(data);
    final user = UserModel.fromJson(json);

    final success = user.email == email && user.password == password;

    if (success) {
      await prefs.setBool(_loggedInKey, true);
    }

    return success;
  }

  @override
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_userKey);
    if (data == null) return null;

    return UserModel.fromJson(jsonDecode(data));
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_loggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }
}
