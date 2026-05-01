import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final int roleIdNum;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.roleIdNum,
  });
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Result<Failure, AuthTokens>> call(RegisterParams params) {
    if (params.email.trim().isEmpty) {
      return Future.value(err(const ValidationFailure('Email é obrigatório.')));
    }
    if (params.password.length < 8) {
      return Future.value(err(const ValidationFailure('Senha deve ter no mínimo 8 caracteres.')));
    }
    return _repository.register(
      email: params.email.trim(),
      password: params.password,
      roleIdNum: params.roleIdNum,
    );
  }
}
