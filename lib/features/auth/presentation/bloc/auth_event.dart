part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
}

final class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final int roleIdNum;
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.roleIdNum,
  });
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
