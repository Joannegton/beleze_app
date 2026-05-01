import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_session.dart';

abstract interface class AuthRepository {
  Future<Result<Failure, AuthTokens>> login({
    required String email,
    required String password,
  });

  Future<Result<Failure, AuthTokens>> register({
    required String email,
    required String password,
    required int roleIdNum,
  });

  Future<Result<Failure, void>> logout();

  Future<Result<Failure, UserSession>> getStoredSession();

  Future<bool> hasValidSession();
}
