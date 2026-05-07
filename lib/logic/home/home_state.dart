import '../../models/user_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel user;
  final Map<String, Map<String, dynamic>> liveData;
  final bool isOffline;

  HomeLoaded({
    required this.user,
    required this.liveData,
    required this.isOffline,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
