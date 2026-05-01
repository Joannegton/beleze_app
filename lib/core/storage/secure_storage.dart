import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userRoleKey = 'user_role';
  static const _userIdKey = 'user_id';
  static const _tenantIdKey = 'tenant_id';

  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveUserInfo({required String userId, required String role}) =>
      Future.wait([
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _userRoleKey, value: role),
      ]).then((_) {});

  Future<String?> getUserRole() => _storage.read(key: _userRoleKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> saveTenantId(String tenantId) =>
      _storage.write(key: _tenantIdKey, value: tenantId);
  Future<String?> getTenantId() => _storage.read(key: _tenantIdKey);

  Future<void> clearTokens() => Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userRoleKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _tenantIdKey),
      ]).then((_) {});
}
