class ApiConfig {
  // ============================================
  // VERSI: TESTING LOKAL (pakai laptop + HP di WiFi yang sama)
  // Gunakan file ini SELAMA proses development & demo pribadi
  // ============================================

  // AKTIF: testing di HP fisik via IP lokal WiFi
  // Cek ulang pakai `ipconfig` di CMD kalau WiFi restart / IP berubah
  static const String baseUrl = 'http://192.168.1.12:3000/api';

  // Untuk testing di Chrome (localhost) — nonaktif:
  // static const String baseUrl = 'http://localhost:3000/api';

  // ============================================

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}