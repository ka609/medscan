import '../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthService {
  AuthService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  // Connexion
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/v1/auth/login',
      data: {'username': username, 'password': password},
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // Utilisateur connecté
  Future<User> getMe() async {
    final response = await _apiClient.get('/v1/auth/me');

    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // Renouvellement du token
  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    final response = await _apiClient.post(
      '/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
