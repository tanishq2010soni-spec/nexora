import 'dart:convert';
import '../storage/secure_storage_service.dart';
import '../constants/storage_constants.dart';

class TokenManager {
  final SecureStorageService _storage;

  TokenManager(this._storage);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.save(StorageConstants.accessTokenKey, accessToken);
    await _storage.save(StorageConstants.refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() =>
      _storage.read(StorageConstants.accessTokenKey);
  Future<String?> getRefreshToken() =>
      _storage.read(StorageConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(StorageConstants.accessTokenKey);
    await _storage.delete(StorageConstants.refreshTokenKey);
  }

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(utf8.decode(base64Url.decode(parts[1])));
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      return DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
      ).isBefore(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      return jsonDecode(utf8.decode(base64Url.decode(parts[1])));
    } catch (_) {
      return null;
    }
  }

  DateTime? getTokenExpiry(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    final exp = payload['exp'] as int?;
    if (exp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }
}
