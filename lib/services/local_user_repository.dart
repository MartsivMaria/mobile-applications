import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class LocalUserRepository implements UserRepository {
  static const _allUsersKey = 'all_users_list';
  static const _currentUserEmailKey = 'current_user_email';
  static const _loggedInKey = 'logged_in';

  @override
  Future<void> register(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    List<UserModel> allUsers = await _getAllUsersList();

    allUsers.removeWhere((u) => u.email == user.email);

    allUsers.add(user);

    final jsonString = jsonEncode(allUsers.map((u) => u.toJson()).toList());
    await prefs.setString(_allUsersKey, jsonString);

    await prefs.setString(_currentUserEmailKey, user.email);
    await prefs.setBool(_loggedInKey, true);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final allUsers = await _getAllUsersList();

    try {
      final user = allUsers.firstWhere(
        (u) => u.email == email && u.password == password,
      );

      await prefs.setString(_currentUserEmailKey, user.email);
      await prefs.setBool(_loggedInKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final currentEmail = prefs.getString(_currentUserEmailKey);
    if (currentEmail == null) return null;

    final allUsers = await _getAllUsersList();
    try {
      return allUsers.firstWhere((u) => u.email == currentEmail);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_currentUserEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  Future<List<UserModel>> _getAllUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_allUsersKey);

    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => UserModel.fromJson(e)).toList();
  }
}
