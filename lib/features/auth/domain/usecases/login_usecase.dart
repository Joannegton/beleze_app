import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<Failure, AuthTokens>> call(LoginParams params) async {
    if (params.email.trim().isEmpty || params.password.isEmpty) {
      const failure = ValidationFailure('Email e senha são obrigatórios.');
      return Future.value(err(failure));
    }

    final result = await _repository.login(
      email: params.email.trim(),
      password: params.password,
    );

    return result;
  }
}
