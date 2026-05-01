import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../models/auth_tokens_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  });
  Future<AuthTokensModel> register({
    required String email,
    required String password,
    required int roleIdNum,
  });
  Future<void> logout();
  Future<String?> getMyTenantId(String accessToken);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasourceImpl(this._dio);

  @override
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return AuthTokensModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthTokensModel> register({
    required String email,
    required String password,
    required int roleIdNum,
  }) async {
    try {
      developer.log(
        '🚀 Sending register request - email: $email, roleIdNum: $roleIdNum',
        name: 'AuthRemoteDatasource',
      );

      final response = await _dio.post(
        'auth/register',
        data: {'email': email, 'password': password, 'roleIdNum': roleIdNum},
      );

      developer.log(
        '✅ Register response status: ${response.statusCode}',
        name: 'AuthRemoteDatasource',
      );
      developer.log(
        '📦 Full response data: ${response.data}',
        name: 'AuthRemoteDatasource',
      );

      return AuthTokensModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log('❌ Register error: $e', name: 'AuthRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> logout() => _dio.post('auth/logout');

  @override
  Future<String?> getMyTenantId(String accessToken) async {
    try {
      final response = await _dio.get(
        'tenants/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final tenantId = response.data['data']['id'] as String?;
      return tenantId;
    } catch (e) {
      return null;
    }
  }
}
