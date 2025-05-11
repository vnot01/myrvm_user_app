// lib/services/auth_service.dart
import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'package:http/http.dart' as http;
import '../utils/api_config.dart'; // Import base URL

class AuthService {
  // Header untuk request ke ngrok jika masih menampilkan halaman peringatan untuk API
  // Jika backend Anda tidak lagi di belakang halaman peringatan ngrok, ini tidak perlu.
  final Map<String, String> _ngrokSkipHeader = {
    'ngrok-skip-browser-warning': 'true',
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          ..._ngrokSkipHeader, // Gabungkan header ngrok jika perlu
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Login sukses, kembalikan data termasuk token
        return {
          'success': true,
          'data': responseData, // Berisi access_token, user, dll.
        };
      } else {
        // Login gagal atau error lain dari server
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'errors': responseData['errors'],
        };
      }
    } catch (error) {
      // Error koneksi atau lainnya
      print('AuthService Login Error: $error'); // Untuk debugging
      return {
        'success': false,
        'message': 'Could not connect to server or an error occurred.',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          ..._ngrokSkipHeader, // Gabungkan header ngrok jika perlu
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 && responseData['status'] == 'success') {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'errors': responseData['errors'],
        };
      }
    } catch (error) {
      print('AuthService Register Error: $error');
      return {
        'success': false,
        'message': 'Could not connect to server or an error occurred.',
      };
    }
  }

  // TODO: Tambahkan metode untuk logout, userProfile, generateRvmToken, googleTokenSignIn nanti
}
