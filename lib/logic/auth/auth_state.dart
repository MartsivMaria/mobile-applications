abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {}

class AuthRegistrationSuccess extends AuthState {
  final String message;
  AuthRegistrationSuccess(this.message);
}

class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}
