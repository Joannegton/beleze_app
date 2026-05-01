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
    final response = await _dio.post(
      'auth/register',
      data: {'email': email, 'password': password, 'roleIdNum': roleIdNum},
    );
    return AuthTokensModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> logout() => _dio.post('auth/logout');
}
