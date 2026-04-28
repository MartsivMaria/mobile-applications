import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth_state.dart';
import '../../services/local_user_repository.dart';
import '../../models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalUserRepository repo;

  AuthCubit(this.repo) : super(AuthInitial());

  Future<bool> _hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError("Будь ласка, заповніть усі поля"));
      return;
    }

    emit(AuthLoading());

    if (!await _hasInternet()) {
      emit(AuthError("Відсутнє підключення до інтернету!"));
      return;
    }

    final success = await repo.login(email, password);
    if (success) {
      emit(AuthLoginSuccess());
    } else {
      emit(AuthError("Неправильний логін або пароль"));
    }
  }

  Future<void> register(UserModel user) async {
    emit(AuthLoading());

    if (!await _hasInternet()) {
      emit(AuthError("Відсутнє підключення до інтернету!"));
      return;
    }

    try {
      await repo.register(user);
      await repo.logout();
      emit(AuthRegistrationSuccess("Акаунт успішно створено! Увійдіть."));
    } catch (e) {
      emit(AuthError("Помилка реєстрації"));
    }
  }
}
