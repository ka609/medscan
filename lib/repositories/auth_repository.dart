import '../core/storage/secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository({AuthService? service, SecureStorage? storage})
    : _service = service ?? AuthService(),
      _storage = storage ?? SecureStorage.instance;

  final AuthService _service;
  final SecureStorage _storage;

  // Connexion
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _service.login(
      username: username,
      password: password,
    );

    await _saveSession(response);

    return response.user;
  }

  // Utilisateur connecté
  Future<User> getMe() async {
    return _service.getMe();
  }

  // Rafraîchir le token
  Future<AuthResponse> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token introuvable.');
    }

    final response = await _service.refreshToken(refreshToken: refreshToken);

    await _saveSession(response);

    return response;
  }

  // Vérifier la session
  Future<bool> isAuthenticated() async {
    final accessToken = await _storage.getAccessToken();

    return accessToken != null && accessToken.isNotEmpty;
  }

  // Déconnexion
  Future<void> logout() async {
    await _storage.clearSession();
  }

  // Sauvegarder la session
  Future<void> _saveSession(AuthResponse response) async {
    await _storage.saveAccessToken(response.accessToken);

    await _storage.saveRefreshToken(response.refreshToken);

    await _storage.saveUserId(response.user.id);
  }
}
