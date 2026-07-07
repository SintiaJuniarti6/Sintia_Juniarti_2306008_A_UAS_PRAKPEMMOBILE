import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });

      return {'success': true, 'message': response.data['message'] ?? 'Registrasi berhasil'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Registrasi gagal, coba lagi'
      };
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'] ?? response.data;
      final token = data['access_token'] ?? data['token'];

      // Simpan token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);

      return {'success': true, 'message': 'Login berhasil'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Email atau password salah'
      };
    }
  }

  // CEK APAKAH SUDAH LOGIN (buat auto-login)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  // AMBIL PROFIL USER
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiService.dio.get('/auth/profile');
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data);
    } on DioException catch (_) {
      return null;
    }
  }

  // UPDATE PROFIL
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      await _apiService.dio.put('/auth/profile', data: {
        'full_name': fullName,
        'phone': phone,
      });
      return {'success': true, 'message': 'Profil berhasil diupdate'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal update profil'
      };
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}