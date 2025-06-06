// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Atau gunakan TokenService Anda
import 'token_service.dart';
import 'package:flutter/foundation.dart';
import '../utils/api_config.dart';
import '../models/deposit_model.dart'; // Import model Deposit Anda

class AuthService {
  final TokenService _tokenService = TokenService();
  // Header untuk request ke ngrok jika masih menampilkan halaman peringatan untuk API
  // Jika backend Anda tidak lagi di belakang halaman peringatan ngrok, ini tidak perlu.
  final Map<String, String> _ngrokSkipHeader = {
    'ngrok-skip-browser-warning': 'true',
  };

  /// Melakukan login pengguna ke backend.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.loginUrl);
    debugPrint('AuthService: Attempting login for $email to $url');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              ..._ngrokSkipHeader,
            },
            body: jsonEncode(<String, String>{
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        'AuthService Login: Response Status Code: ${response.statusCode}',
      );
      debugPrint('AuthService Login: Response Body: ${response.body}');

      Map<String, dynamic>? responseData;
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        } else {
          if (response.statusCode != 200) {
            debugPrint(
              'AuthService Login: Empty response body with non-200 status.',
            );
            return {
              'success': false,
              'message':
                  'Received empty response from server (Status: ${response.statusCode}).',
            };
          }
          responseData = null;
        }
      } catch (e) {
        debugPrint(
          'AuthService Login: Failed to decode JSON response body: $e',
        );
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }

      if (response.statusCode == 200 &&
          responseData != null &&
          responseData['status'] == 'success') {
        final String? token = responseData['access_token'] as String?;
        final Map<String, dynamic>? userData =
            responseData['user'] as Map<String, dynamic>?;
        final String? userName = userData?['name'] as String?;
        final int? userId = userData?['id'] as int?;

        if (token != null && userName != null && userId != null) {
          await _tokenService.saveTokenAndUserDetails(token, userName, userId);
          debugPrint(
            'AuthService Login: Login successful. Token and user details saved.',
          );
          return {
            'success': true,
            'data': responseData,
          }; // Kembalikan semua responseData agar fleksibel
        } else {
          debugPrint(
            'AuthService Login: Success status from API but missing token/user data in response structure.',
          );
          return {
            'success': false,
            'message': 'Login response from server was incomplete.',
          };
        }
      } else {
        String message = 'Login failed.';
        if (responseData != null && responseData['message'] != null) {
          message = responseData['message'] as String;
        } else if (response.reasonPhrase != null &&
            response.reasonPhrase!.isNotEmpty) {
          message = response.reasonPhrase!;
        } else if (responseData != null && responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstErrorField = errors.keys.first;
            final firstErrorMessage =
                (errors[firstErrorField] as List<dynamic>?)?.first as String?;
            if (firstErrorMessage != null) {
              message = firstErrorMessage;
            }
          }
        }
        debugPrint(
          'AuthService Login: Login failed on server. Status: ${response.statusCode}, Message: $message',
        );
        return {
          'success': false,
          'message': message,
          'errors': responseData?['errors'] as Map<String, dynamic>?,
        };
      }
    } catch (error) {
      debugPrint('AuthService Login: Exception during login request: $error');
      String errorMessage =
          'Could not connect to the server or an unexpected error occurred.';
      if (error is http.ClientException || error is SocketException) {
        errorMessage =
            'Failed to connect to the server. Please check your internet connection.';
      } else if (error is TimeoutException) {
        errorMessage =
            'The connection to the server timed out. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  /// Melakukan registrasi pengguna baru ke backend.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse(ApiConfig.registerUrl);
    debugPrint('AuthService: Attempting registration for $email to $url');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              ..._ngrokSkipHeader,
            },
            body: jsonEncode(<String, String>{
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        'AuthService Register: Response Status Code: ${response.statusCode}',
      );
      debugPrint('AuthService Register: Response Body: ${response.body}');

      Map<String, dynamic>? responseData;
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        } else {
          if (response.statusCode != 201) {
            debugPrint(
              'AuthService Register: Empty response body with non-201 status.',
            );
            return {
              'success': false,
              'message':
                  'Received empty response from server (Status: ${response.statusCode}).',
            };
          }
          responseData = null;
        }
      } catch (e) {
        debugPrint(
          'AuthService Register: Failed to decode JSON response body: $e',
        );
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }

      if (response.statusCode == 201 &&
          responseData != null &&
          responseData['status'] == 'success') {
        final String? token = responseData['access_token'] as String?;
        final Map<String, dynamic>? userData =
            responseData['user'] as Map<String, dynamic>?;
        final String? userName = userData?['name'] as String?;
        final int? userId = userData?['id'] as int?;

        if (token != null && userName != null && userId != null) {
          await _tokenService.saveTokenAndUserDetails(token, userName, userId);
          debugPrint(
            'AuthService Register: Registration successful. Token and user details saved.',
          );
          return {'success': true, 'data': responseData};
        } else {
          debugPrint(
            'AuthService Register: Success status from API but missing token/user data.',
          );
          return {
            'success': false,
            'message': 'Registration response from server was incomplete.',
          };
        }
      } else {
        String message = 'Registration failed.';
        if (responseData != null && responseData['message'] != null) {
          message = responseData['message'] as String;
        } else if (response.reasonPhrase != null &&
            response.reasonPhrase!.isNotEmpty) {
          message = response.reasonPhrase!;
        } else if (responseData != null && responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstErrorField = errors.keys.first;
            final firstErrorMessage =
                (errors[firstErrorField] as List<dynamic>?)?.first as String?;
            if (firstErrorMessage != null) {
              message = firstErrorMessage;
            }
          }
        }
        debugPrint(
          'AuthService Register: Registration failed on server. Status: ${response.statusCode}, Message: $message',
        );
        return {
          'success': false,
          'message': message,
          'errors': responseData?['errors'] as Map<String, dynamic>?,
        };
      }
    } catch (error) {
      debugPrint(
        'AuthService Register: Exception during registration request: $error',
      );
      String errorMessage =
          'Could not connect or an unexpected error occurred.';
      if (error is http.ClientException || error is SocketException) {
        errorMessage =
            'Failed to connect to the server. Please check your internet connection.';
      } else if (error is TimeoutException) {
        errorMessage =
            'The connection to the server timed out. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  /// Melakukan logout pengguna.
  Future<void> logout() async {
    final token = await _tokenService.getToken();
    if (token != null) {
      final url = Uri.parse(ApiConfig.logoutUrl);
      debugPrint('AuthService: Attempting logout from $url');
      try {
        await http
            .post(
              url,
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                ..._ngrokSkipHeader,
              },
            )
            .timeout(const Duration(seconds: 10));
        debugPrint('AuthService: Logout API call successful or attempted.');
      } catch (e) {
        debugPrint('AuthService: Error calling logout API: $e');
      }
    }
    await _tokenService.deleteTokenAndUserDetails(); // Selalu hapus token lokal
    debugPrint('AuthService: Local token and user details deleted.');
  }

  /// Mengambil profil pengguna yang sedang terotentikasi.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await _tokenService.getToken();
    if (token == null) {
      debugPrint('AuthService GetProfile: No local token found.');
      return null;
    }
    final url = Uri.parse(ApiConfig.profileUrl);
    debugPrint('AuthService: Attempting to get user profile from $url');
    try {
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              ..._ngrokSkipHeader,
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'AuthService GetProfile: Response Status Code: ${response.statusCode}',
      );
      // Bisa sangat panjang
      debugPrint('AuthService GetProfile: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Backend Laravel /auth/user langsung mengembalikan objek user, bukan dibungkus 'status' atau 'data'
        // debugPrint('AuthService GetProfile: Raw Response Data: $responseData');
        if (responseData is Map<String, dynamic>) {
          // Pastikan ini adalah Map
          debugPrint('AuthService GetProfile: Profile retrieved successfully.');
          return responseData; // Ini adalah objek user
        } else {
          debugPrint(
            'AuthService GetProfile: Profile response is not a valid map.',
          );
          return null;
        }
      } else {
        debugPrint(
          'AuthService GetProfile: Failed to get profile. Status: ${response.statusCode}',
        );
        if (response.statusCode == 401) {
          // Token tidak valid/kadaluarsa
          await _tokenService.deleteTokenAndUserDetails();
        }
        return null;
      }
    } catch (e) {
      debugPrint('AuthService: Error fetching user profile: $e');
      return null;
    }
  }

  /// Men-generate token RVM sementara untuk login di mesin RVM.
  Future<Map<String, dynamic>> generateRvmLoginToken() async {
    final token = await _tokenService.getToken(); // Sanctum token pengguna
    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated for generating RVM token.',
      };
    }
    final url = Uri.parse(ApiConfig.generateRvmTokenUrl);
    debugPrint('AuthService: Attempting to generate RVM login token from $url');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              ..._ngrokSkipHeader,
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'AuthService GenerateRVMToken: Response Status Code: ${response.statusCode}',
      );
      // Bisa sangat panjang
      debugPrint(
        'AuthService GenerateRVMToken: Response Body: ${response.body}',
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        debugPrint(
          'AuthService GenerateRVMToken: Token generated successfully.',
        );
        // Berisi rvm_login_token & expires_in_seconds
        return {'success': true, 'data': responseData['data']};
      } else {
        debugPrint(
          'AuthService GenerateRVMToken: Failed. Message: ${responseData['message']}',
        );
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to generate RVM token',
        };
      }
    } catch (e) {
      debugPrint('AuthService: Error generating RVM token: $e');
      return {
        'success': false,
        'message':
            'Could not connect or error occurred while generating RVM token.',
      };
    }
  }

  /// Memeriksa status scan token RVM ke backend.
  Future<Map<String, dynamic>> checkRvmScanStatus(
    String rvmLoginTokenToCheck,
  ) async {
    // Sanctum token pengguna
    final token = await _tokenService.getToken();
    if (token == null) {
      return {
        'success': false,
        'status': 'error',
        'message': 'User not authenticated for checking scan status.',
      };
    }

    final url = Uri.parse(
      '${ApiConfig.checkRvmScanStatusUrl}?token=$rvmLoginTokenToCheck',
    );
    debugPrint(
      'AuthService: Checking RVM scan status for token: $rvmLoginTokenToCheck',
    );
    try {
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              ..._ngrokSkipHeader,
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'AuthService CheckScanStatus: Response Status Code: ${response.statusCode}',
      );
      // debugPrint(
      //   'AuthService CheckScanStatus: Response Body: ${response.body}',
      // );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('AuthService CheckScanStatus: Parsed Data: $responseData');
        // Backend diharapkan mengembalikan:
        // {'status': 'pending_scan' / 'scanned_and_validated' / 'token_expired_or_invalid' / dll.}
        return {'success': true, ...responseData};
      } else {
        debugPrint(
          'AuthService CheckScanStatus: Failed. Status: ${response.statusCode}',
        );
        return {
          'success': false,
          'status': 'error',
          'message':
              'Failed to check scan status (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('AuthService: Error checking RVM scan status: $e');
      return {
        'success': false,
        'status': 'error',
        'message': 'Connection error or timeout checking scan status.',
      };
    }
  }

  Future<Map<String, dynamic>> getDepositHistory({int page = 1}) async {
    // GUNAKAN TokenService untuk mengambil token:
    final token = await _tokenService.getToken();
    debugPrint(
      'AuthService: Mencoba mengambil token via TokenService. Hasil: ${token != null ? "Token Ditemukan" : "Token NULL"}',
    );

    if (token == null) {
      debugPrint('AuthService: Token tidak ditemukan untuk getDepositHistory.');
      return {
        'success': false,
        'message': 'User not authenticated.',
        'data': <Deposit>[],
      };
    }

    final Uri uri = Uri.parse('${ApiConfig.historyUrl}?page=$page');
    debugPrint('AuthService: Memanggil GET $uri');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              ..._ngrokSkipHeader,
            },
          )
          .timeout(const Duration(seconds: 15)); // Tambahkan timeout

      debugPrint(
        'AuthService: getDepositHistory status code: ${response.statusCode}',
      );
      // debugPrint('AuthService: getDepositHistory response body: ${response.body}'); // Hati-hati jika body besar

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Asumsi API mengembalikan struktur paginasi Laravel: { data: [...], links: {...}, meta: {...} }
        // Pastikan responseData adalah Map dan memiliki key 'data' yang juga Map
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is Map<String, dynamic>) {
          // Akses objek paginasi // Ambil nilai 'data' dulu
          final Map<String, dynamic> paginationData = responseData['data'];
          // Akses list 'data' di dalam objek paginasi
          // Beri default list kosong jika key 'data' tidak ada atau null
          final List<dynamic> depositsJson =
              paginationData['data'] as List<dynamic>? ?? [];
          // Parsing list JSON menjadi List<Deposit>
          final List<Deposit> deposits =
              depositsJson
                  .map((json) => Deposit.fromJson(json as Map<String, dynamic>))
                  .toList();

          debugPrint(
            'AuthService: Berhasil mendapatkan ${deposits.length} item riwayat.',
          );
          // Kembalikan hasil termasuk data paginasi
          return {
            'success': true,
            'message': 'History fetched successfully',
            'data': deposits, // List<Deposit>
            // Ambil meta dan links dari objek paginasi
            'meta': paginationData['meta'],
            'links': paginationData['links'],
          };
        } else {
          // Jika struktur utama { data: { ... } } tidak ditemukan
          debugPrint(
            'AuthService: Format respons paginasi tidak sesuai harapan.',
          );
          return {
            'success': false,
            'message': 'Invalid pagination response format.',
            'data': <Deposit>[],
          };
        }
        // --- AKHIR PERBAIKAN ---
      } else if (response.statusCode == 401) {
        // ... (kode error 401 tetap sama) ...
        debugPrint(
          'AuthService: Gagal getDepositHistory - Unauthenticated (401).',
        );
        await _tokenService
            .deleteTokenAndUserDetails(); // Logout otomatis jika token tidak valid
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
          'data': <Deposit>[],
        };
      } else {
        String errorMessage =
            'Failed to fetch history. Status code: ${response.statusCode}';
        try {
          // Coba parse pesan error dari backend jika ada
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          }
        } catch (e) {
          // Biarkan errorMessage default jika parsing gagal
          debugPrint('AuthService: Exception saat Gagal Parse - Status: $e');
        }
        debugPrint(
          'AuthService: Gagal getDepositHistory - Status: ${response.statusCode}',
        );
        // ... (parsing pesan error) ...
        return {'success': false, 'message': errorMessage, 'data': <Deposit>[]};
      }
    } catch (e) {
      debugPrint('AuthService: Exception saat getDepositHistory: $e');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'data': <Deposit>[],
      };
    }
  }
}
