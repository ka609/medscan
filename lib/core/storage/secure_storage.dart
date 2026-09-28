import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorage {
  SecureStorage._();

  static final SecureStorage instance = SecureStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Général
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> contains(String key) async {
    return _storage.containsKey(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Access token
  Future<void> saveAccessToken(String token) async {
    await write(StorageKeys.accessToken, token);
  }

  Future<String?> getAccessToken() async {
    return read(StorageKeys.accessToken);
  }

  Future<void> deleteAccessToken() async {
    await delete(StorageKeys.accessToken);
  }

  // Refresh token
  Future<void> saveRefreshToken(String token) async {
    await write(StorageKeys.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return read(StorageKeys.refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await delete(StorageKeys.refreshToken);
  }

  // Type du token
  Future<void> saveTokenType(String tokenType) async {
    await write(StorageKeys.tokenType, tokenType);
  }

  Future<String?> getTokenType() async {
    return read(StorageKeys.tokenType);
  }

  // Expiration
  Future<void> saveExpiresAt(DateTime expiresAt) async {
    await write(StorageKeys.expiresAt, expiresAt.toIso8601String());
  }

  Future<DateTime?> getExpiresAt() async {
    final value = await read(StorageKeys.expiresAt);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  // Utilisateur
  Future<void> saveUserId(String userId) async {
    await write(StorageKeys.userId, userId);
  }

  Future<String?> getUserId() async {
    return read(StorageKeys.userId);
  }

  Future<void> savePatientId(String patientId) async {
    await write(StorageKeys.patientId, patientId);
  }

  Future<String?> getPatientId() async {
    return read(StorageKeys.patientId);
  }

  Future<void> saveUserRole(String role) async {
    await write(StorageKeys.userRole, role);
  }

  Future<String?> getUserRole() async {
    return read(StorageKeys.userRole);
  }

  // Données utilisateur
  Future<void> saveUser(Map<String, dynamic> user) async {
    await write(StorageKeys.userData, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final value = await read(StorageKeys.userData);

    if (value == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // Session
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
    String? userId,
    String? patientId,
    String? role,
    Map<String, dynamic>? user,
  }) async {
    await saveAccessToken(accessToken);

    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }

    if (tokenType != null) {
      await saveTokenType(tokenType);
    }

    if (expiresAt != null) {
      await saveExpiresAt(expiresAt);
    }

    if (userId != null) {
      await saveUserId(userId);
    }

    if (patientId != null) {
      await savePatientId(patientId);
    }

    if (role != null) {
      await saveUserRole(role);
    }

    if (user != null) {
      await saveUser(user);
    }
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }

  Future<bool> isAccessTokenExpired() async {
    final expiresAt = await getExpiresAt();

    if (expiresAt == null) {
      return false;
    }

    return DateTime.now().isAfter(expiresAt);
  }

  Future<void> clearSession() async {
    await delete(StorageKeys.accessToken);
    await delete(StorageKeys.refreshToken);
    await delete(StorageKeys.tokenType);
    await delete(StorageKeys.expiresAt);
    await delete(StorageKeys.userId);
    await delete(StorageKeys.patientId);
    await delete(StorageKeys.userRole);
    await delete(StorageKeys.userData);
  }
}
