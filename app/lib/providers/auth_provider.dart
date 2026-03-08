import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  String? _userEmail;
  String? _userRole;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _userRole == 'admin';
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null) {
      _token = savedToken;
      apiService.setToken(savedToken);
      try {
        final data = await apiService.getMe();
        final user = data['user'] as Map<String, dynamic>;
        _userName = user['name'] as String?;
        _userEmail = user['email'] as String?;
        _userRole = user['role'] as String?;
      } catch (_) {
        // Token expired or invalid — clear it
        await _clearSession();
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await apiService.login(email, password);
      await _saveSession(data);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await apiService.register(name, email, password);
      await _saveSession(data);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    _token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    _userName = user['name'] as String?;
    _userEmail = user['email'] as String?;
    _userRole = user['role'] as String?;
    apiService.setToken(_token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
  }

  Future<void> _clearSession() async {
    _token = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    apiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
