import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthBloc({
    required AuthRepository authRepository,
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  })  : _authRepository = authRepository,
        _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.getStoredSession();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    developer.log('[AuthBloc] Login iniciado para email: ${event.email}');
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    developer.log('[AuthBloc] Login resultado - isFailure: ${result.isFailure}');

    if (result.isFailure) {
      final errorMsg = result.error.message;
      developer.log('[AuthBloc] Login falhou: $errorMsg', error: result.error);
      emit(AuthFailure(errorMsg));
      return;
    }

    developer.log('[AuthBloc] Login sucesso, buscando sessão armazenada');
    final session = await _authRepository.getStoredSession();
    session.fold(
      (_) {
        developer.log('[AuthBloc] Erro ao recuperar sessão');
        emit(const AuthUnauthenticated());
      },
      (s) {
        developer.log('[AuthBloc] Sessão recuperada: ${s.email}');
        emit(AuthAuthenticated(s));
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        roleIdNum: event.roleIdNum,
      ),
    );

    if (result.isFailure) {
      emit(AuthFailure(result.error.message));
      return;
    }

    final session = await _authRepository.getStoredSession();
    session.fold(
      (_) => emit(const AuthUnauthenticated()),
      (s) => emit(AuthAuthenticated(s)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
