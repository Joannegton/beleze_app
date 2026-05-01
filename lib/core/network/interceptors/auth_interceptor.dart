import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

typedef OnSessionExpired = Future<void> Function();

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final OnSessionExpired? onSessionExpired;

  AuthInterceptor(
    this._secureStorage, {
    this.onSessionExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken(err.requestOptions);
      if (refreshed != null) {
        handler.resolve(refreshed);
        return;
      }
      await _secureStorage.clearTokens();
      await onSessionExpired?.call();
    }
    handler.next(err);
  }

  Future<Response?> _tryRefreshToken(RequestOptions options) async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final dio = Dio();
      final response = await dio.post(
        '${options.baseUrl}auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final accessToken = response.data['data']['accessToken'] as String?;
      if (accessToken == null) return null;

      await _secureStorage.saveAccessToken(accessToken);

      options.headers['Authorization'] = 'Bearer $accessToken';
      return await dio.fetch(options);
    } catch (_) {
      return null;
    }
  }
}
