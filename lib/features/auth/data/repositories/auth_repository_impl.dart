import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._datasource, this._secureStorage);

  @override
  Future<Result<Failure, AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokens = await _datasource.login(email: email, password: password);
      await _saveSession(tokens);
      return ok(tokens);
    } on DioException catch (e) {
      return err(_mapDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<Failure, AuthTokens>> register({
    required String email,
    required String password,
    required int roleIdNum,
  }) async {
    try {
      final tokens = await _datasource.register(
        email: email,
        password: password,
        roleIdNum: roleIdNum,
      );
      await _saveSession(tokens);
      return ok(tokens);
    } on DioException catch (e) {
      return err(_mapDioError(e));
    }
  }

  @override
  Future<Result<Failure, void>> logout() async {
    try {
      await _datasource.logout();
      await _secureStorage.clearTokens();
      return ok(null);
    } on DioException catch (e) {
      await _secureStorage.clearTokens();
      return err(_mapDioError(e));
    }
  }

  @override
  Future<Result<Failure, UserSession>> getStoredSession() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        return err(const UnauthorizedFailure());
      }

      final payload = _decodeJwt(token);
      if (payload == null) {
        return err(const UnauthorizedFailure());
      }

      final roleIdNum = _extractRoleIdNum(payload);

      if (roleIdNum == null) {
        return err(const UnauthorizedFailure());
      }

      final role = UserRole.fromRoleIdNum(roleIdNum);

      var tenantId = payload['tenant_id'] as String?;
      tenantId ??= await _secureStorage.getTenantId();

      final session = UserSession(
        userId: payload['sub'] as String,
        email: payload['email'] as String,
        role: role,
        tenantId: tenantId,
      );

      return ok(session);
    } catch (e) {
      developer.log('❌ Erro ao obter sessão: $e', name: 'AuthRepository');
      return err(const UnauthorizedFailure());
    }
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) return false;

    final payload = _decodeJwt(token);
    if (payload == null) return false;

    final exp = payload['exp'] as int?;
    if (exp == null) return false;

    return DateTime.fromMillisecondsSinceEpoch(
      exp * 1000,
    ).isAfter(DateTime.now());
  }

  Future<void> _saveSession(AuthTokens tokens) async {
    await _secureStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    final payload = _decodeJwt(tokens.accessToken);
    if (payload != null) {
      final roleIdNum = _extractRoleIdNum(payload);

      if (roleIdNum == null) {
        await _secureStorage.clearTokens();
        return;
      }

      final role = UserRole.fromRoleIdNum(roleIdNum);

      await _secureStorage.saveUserInfo(
        userId: payload['sub'] as String? ?? '',
        role: role.label,
      );

      if (roleIdNum == UserRole.owner.roleIdNum) {
        final tenantId = await _datasource.getMyTenantId(tokens.accessToken);
        if (tenantId != null) {
          await _secureStorage.saveTenantId(tenantId);
        } else {
          await _secureStorage.clearTokens();
          return; // ver se isso nao quebra
        }
      }
    } else {
      developer.log('⚠️ Falha ao salvar sessão', name: 'AuthRepository');
    }
  }

  int? _extractRoleIdNum(Map<String, dynamic> payload) {
    var roleValue = payload['roles'];

    if (roleValue is List && roleValue.isNotEmpty) {
      roleValue = roleValue.first;
    }

    if (roleValue is int) {
      return roleValue;
    }
    return null;
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final result = jsonDecode(decoded) as Map<String, dynamic>;
      return result;
    } catch (e) {
      return null;
    }
  }

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.message ?? 'Erro inesperado.';

    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      404 => NotFoundFailure(message),
      _ when e.type == DioExceptionType.connectionError =>
        const NetworkFailure(),
      _ => ServerFailure(message, statusCode: statusCode),
    };
  }
}
