class ApiConfig {
  // ============================================
  // GANTI baseUrl DI BAWAH SESUAI TARGET TESTING
  // ============================================

  // AKTIF SEKARANG: testing di Chrome (localhost)
  static const String baseUrl = 'http://localhost:3000/api';

  // Untuk testing di HP fisik, comment baris di atas,
  // lalu uncomment baris di bawah ini (sesuaikan IP kalau berubah,
  // cek ulang pakai `ipconfig` di CMD kalau WiFi restart):
  // static const String baseUrl = 'http://192.168.100.24:3000/api';

  // Untuk testing pakai server online dosen (fallback kalau server
  // lokal down atau mau tes final):
  // static const String baseUrl = 'https://api-tb-f2wk.onrender.com/api';

  // ============================================

  // Timeout durasi request (biar konsisten dipakai di ApiService)
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}