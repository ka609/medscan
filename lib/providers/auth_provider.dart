import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isAuthenticated => _user != null;

  Future<bool> checkAuthentication() async {
    _setLoading(true);
    _clearError();

    try {
      final authenticated = await _repository.isAuthenticated();

      if (!authenticated) {
        _user = null;
        return false;
      }

      _user = await _repository.getMe();

      return true;
    } catch (e) {
      _error = e.toString();
      _user = null;

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _repository.login(username: username, password: password);

      return true;
    } catch (e) {
      _error = e.toString();
      _user = null;

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refreshSession() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.refreshToken();

      _user = response.user;

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMe() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _repository.getMe();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _repository.logout();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
