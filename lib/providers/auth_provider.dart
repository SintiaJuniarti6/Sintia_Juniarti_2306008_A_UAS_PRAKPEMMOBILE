import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // Dipanggil pas app pertama kali dibuka (cek auto-login)
  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      await fetchProfile();
    }
    notifyListeners();
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    if (result['success']) {
      _isLoggedIn = true;
      await fetchProfile();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // AMBIL PROFIL
  Future<void> fetchProfile() async {
    final profile = await _authService.getProfile();
    if (profile != null) {
      _user = profile;
      notifyListeners();
    }
  }

  // UPDATE PROFIL
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    final result = await _authService.updateProfile(fullName: fullName, phone: phone);
    if (result['success']) {
      await fetchProfile(); // refresh data terbaru
    }
    return result;
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}