import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/local_user_repository.dart';
import '../../models/user_model.dart';
import '../../mqtt/api_service.dart';
import 'profile_state.dart';

class UserCubit extends Cubit<UserState> {
  final LocalUserRepository _repo;

  UserCubit(this._repo) : super(UserInitial());

  Future<void> loadUser() async {
    emit(UserLoading());
    try {
      final user = await _repo.getUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError("Користувача не знайдено"));
      }
    } catch (e) {
      emit(UserError("Помилка завантаження: $e"));
    }
  }

  Future<void> updateName(String newName) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = currentUser.copyWith(fullName: newName);
      await _repo.register(updatedUser);
      emit(UserLoaded(updatedUser));
    }
  }

  Future<void> addRoom(String roomName) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      await ApiService.addRoom(roomName);

      final updatedRooms = List<String>.from(currentUser.rooms)..add(roomName);
      final updatedUser = currentUser.copyWith(rooms: updatedRooms);

      await _repo.register(updatedUser);
      emit(UserLoaded(updatedUser));
    }
  }

  Future<void> deleteRoom(int index) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedRooms = List<String>.from(currentUser.rooms)
        ..removeAt(index);
      final updatedUser = currentUser.copyWith(rooms: updatedRooms);

      await _repo.register(updatedUser);
      emit(UserLoaded(updatedUser));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
  }
}
