class ApiConfig {
  // ============================================
  // GANTI baseUrl DI BAWAH SESUAI TARGET TESTING
  // ============================================

  // Untuk testing di Chrome (localhost) - development lokal:
  // static const String baseUrl = 'http://localhost:3000/api';

  // Untuk testing di HP fisik via WiFi yang sama:
  // static const String baseUrl = 'http://192.168.100.24:3000/api';

  // AKTIF SEKARANG: server online dosen (WAJIB untuk build APK final/submission)
  static const String baseUrl = 'https://api-tb-f2wk.onrender.com/api';

  // ============================================

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}