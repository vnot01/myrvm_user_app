// lib/utils/api_config.dart
class ApiConfig {
  // Ganti dengan URL ngrok atau server backend Laravel Anda
  static const String baseUrl =
      "https://precious-puma-smoothly.ngrok-free.app/api";
  // Header untuk ngrok jika masih diperlukan (biasanya tidak untuk API call langsung jika sudah dikonfigurasi)
  // Jika backend API Anda di-hosting langsung (bukan via ngrok dev), header ini tidak perlu.
  // Untuk sekarang kita tidak sertakan di sini, tapi bisa ditambahkan di service jika perlu.

  static const String loginUrl = "$baseUrl/auth/login";
  static const String logoutUrl = "$baseUrl/auth/logout";
  static const String profileUrl = "$baseUrl/auth/user";
  static const String registerUrl = "$baseUrl/auth/register";
  static const String generateRvmTokenUrl = "$baseUrl/user/generate-rvm-token";
  static const String checkRvmScanStatusUrl =
      "$baseUrl/user/check-rvm-scan-status";
  static const String historyUrl = "$baseUrl/user/deposit-history";
}
