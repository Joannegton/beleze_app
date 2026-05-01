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
  }) : _authRepository = authRepository,
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
    developer.log('🔍 Checking stored session...', name: 'AuthBloc');
    emit(const AuthLoading());
    final result = await _authRepository.getStoredSession();
    result.fold(
      (error) {
        developer.log('❌ No valid session found', name: 'AuthBloc');
        emit(const AuthUnauthenticated());
      },
      (session) {
        developer.log(
          '✅ Session found - Role: ${session.role.label} (${session.role.roleIdNum})',
          name: 'AuthBloc',
        );
        emit(AuthAuthenticated(session));
      },
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    if (result.isFailure) {
      final errorMsg = result.error.message;
      emit(AuthFailure(errorMsg));
      return;
    }

    final session = await _authRepository.getStoredSession();
    session.fold(
      (error) {
        emit(
          const AuthFailure(
            'Erro ao processar dados de autenticação. Por favor, entre em contato com o suporte.',
          ),
        );
      },
      (s) {
        emit(AuthAuthenticated(s));
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    developer.log(
      '📝 Register started - email: ${event.email}, roleIdNum: ${event.roleIdNum}',
      name: 'AuthBloc',
    );
    emit(const AuthLoading());
    final result = await _registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        roleIdNum: event.roleIdNum,
      ),
    );

    if (result.isFailure) {
      developer.log(
        '❌ Register failed: ${result.error.message}',
        name: 'AuthBloc',
      );
      emit(AuthFailure(result.error.message));
      return;
    }

    developer.log(
      '✅ Register use case succeeded, retrieving stored session...',
      name: 'AuthBloc',
    );

    final session = await _authRepository.getStoredSession();
    session.fold(
      (error) {
        developer.log(
          '❌ Failed to retrieve session after register',
          name: 'AuthBloc',
        );
        emit(const AuthUnauthenticated());
      },
      (s) {
        developer.log(
          '✅ Register complete - User: ${s.email}, Role: ${s.role.label} (${s.role.roleIdNum})',
          name: 'AuthBloc',
        );
        emit(AuthAuthenticated(s));
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    developer.log('🚪 Logout requested', name: 'AuthBloc');
    await _authRepository.logout();
    developer.log('✅ Logout complete', name: 'AuthBloc');
    emit(const AuthUnauthenticated());
  }
}
