// // lib/services/auth_service.dart
// import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
// import 'dart:async'; // Untuk TimeoutException
// import 'dart:io'; // Untuk SocketException
// import 'package:http/http.dart' as http;
// import '../utils/api_config.dart'; // Import base URL
// import 'token_service.dart'; // Import TokenService
// import 'package:flutter/foundation.dart'; // Untuk debugPrint

// class AuthService {
//   final TokenService _tokenService = TokenService(); // Instance TokenService
//   // Header untuk request ke ngrok jika masih menampilkan halaman peringatan untuk API
//   // Jika backend Anda tidak lagi di belakang halaman peringatan ngrok, ini tidak perlu.
//   final Map<String, String> _ngrokSkipHeader = {
//     'ngrok-skip-browser-warning': 'true',
//   };

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
//     debugPrint('AuthService: Attempting login for $email to $url');
//     try {
//       final response = await http
//           .post(
//             url,
//             headers: {
//               'Content-Type': 'application/json; charset=UTF-8',
//               'Accept': 'application/json',
//               ..._ngrokSkipHeader, // Gabungkan header ngrok jika perlu
//             },
//             body: jsonEncode(<String, String>{
//               'email': email,
//               'password': password,
//             }),
//           )
//           .timeout(
//             const Duration(seconds: 15),
//           ); // Tambahkan timeout untuk request

//       debugPrint(
//         'AuthService Login: Response Status Code: ${response.statusCode}',
//       );
//       debugPrint('AuthService Login: Response Body: ${response.body}');

//       Map<String, dynamic>? responseData;

//       try {
//         if (response.body.isNotEmpty) {
//           responseData = jsonDecode(response.body);
//         } else {
//           // Jika body kosong tapi status bukan 200, ini masalah
//           if (response.statusCode != 200) {
//             debugPrint(
//               'AuthService Login: Empty response body with non-200 status.',
//             );
//             return {
//               'success': false,
//               'message':
//                   'Received empty response from server (Status: ${response.statusCode}).',
//             };
//           }
//           // Jika body kosong dan status 200 (jarang terjadi untuk login API), anggap gagal
//           responseData = null;
//         }
//       } catch (e) {
//         // jika decode gagal
//         debugPrint(
//           'AuthService Login: Failed to decode JSON response body: $e',
//         );
//         return {
//           'success': false,
//           'message': 'Invalid response format from server.',
//         };
//       }

//       if (response.statusCode == 200 &&
//           responseData != null &&
//           responseData['status'] == 'success') {
//         // --- PERBAIKAN EKSTRAKSI DATA ---
//         final String? token =
//             responseData['access_token']
//                 as String?; // Ambil langsung dari responseData
//         final Map<String, dynamic>? userData =
//             responseData['user']
//                 as Map<String, dynamic>?; // Ambil langsung dari responseData
//         final String? userName = userData?['name'] as String?;
//         final int? userId = userData?['id'] as int?;
//         // --- AKHIR PERBAIKAN EKSTRAKSI DATA ---
//         if (token != null && userName != null && userId != null) {
//           await _tokenService.saveTokenAndUserDetails(token, userName, userId);
//           debugPrint(
//             'AuthService Login: Login successful. Token and user details saved.',
//           );
//           // Kembalikan data asli jika sukses
//           // return {
//           //   'success': true,
//           //   'data': responseData['data'],
//           // };
//           return {
//             'success': true,
//             'data': {
//               // Kita buat struktur 'data' di sini jika diperlukan oleh UI
//               'access_token': token,
//               'user': userData,
//             },
//           };
//         } else {
//           debugPrint(
//             'AuthService Login: Success status but missing token/user data in response.',
//           );
//           return {'success': false, 'message': 'Login response incomplete.'};
//         }
//       } else {
//         // Login gagal atau error lain dari server
//         // Login gagal di sisi server atau error lain
//         String message = 'Login failed.'; // Default message
//         if (responseData != null && responseData['message'] != null) {
//           message = responseData['message'] as String;
//         } else if (response.reasonPhrase != null &&
//             response.reasonPhrase!.isNotEmpty) {
//           message = response.reasonPhrase!;
//         } else if (responseData != null && responseData['errors'] != null) {
//           // Coba ambil pesan error pertama dari validasi
//           final errors = responseData['errors'] as Map<String, dynamic>?;
//           if (errors != null && errors.isNotEmpty) {
//             final firstErrorField = errors.keys.first;
//             final firstErrorMessage =
//                 (errors[firstErrorField] as List<dynamic>?)?.first as String?;
//             if (firstErrorMessage != null) {
//               message = firstErrorMessage;
//             }
//           }
//         }
//         debugPrint(
//           'AuthService Login: Login failed on server. Status: ${response.statusCode}, Message: $message',
//         );

//         return {
//           'success': false,
//           'message': message,
//           'errors': responseData?['errors'] as Map<String, dynamic>?,
//         };
//       }
//     } catch (error) {
//       // Error koneksi atau lainnya
//       debugPrint('AuthService Login: Exception during login request: $error');
//       String errorMessage =
//           'Could not connect to the server or an unexpected error occurred.';
//       if (error is http.ClientException ||
//           error is TimeoutException ||
//           error is SocketException) {
//         errorMessage =
//             'An unknown error occurred during login. Please check your internet connection.';
//       }
//       // Fallback
//       return {'success': false, 'message': errorMessage};
//     }
//   }

//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//     required String passwordConfirmation,
//   }) async {
//     final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
//     debugPrint('AuthService: Attempting registration for $email to $url');
//     try {
//       final response = await http
//           .post(
//             url,
//             headers: {
//               'Content-Type': 'application/json; charset=UTF-8',
//               'Accept': 'application/json',
//               ..._ngrokSkipHeader,
//             },
//             body: jsonEncode(<String, String>{
//               'name': name,
//               'email': email,
//               'password': password,
//               'password_confirmation': passwordConfirmation,
//             }),
//           )
//           .timeout(const Duration(seconds: 15));

//       debugPrint(
//         'AuthService Register: Response Status Code: ${response.statusCode}',
//       );
//       debugPrint('AuthService Register: Response Body: ${response.body}');

//       Map<String, dynamic>? responseData;
//       try {
//         if (response.body.isNotEmpty) {
//           responseData = jsonDecode(response.body);
//         } else {
//           if (response.statusCode != 201) {
//             // Status 201 untuk register sukses
//             debugPrint(
//               'AuthService Register: Empty response body with non-201 status.',
//             );
//             return {
//               'success': false,
//               'message':
//                   'Received empty response from server (Status: ${response.statusCode}).',
//             };
//           }
//           responseData = null;
//         }
//       } catch (e) {
//         debugPrint(
//           'AuthService Register: Failed to decode JSON response body: $e',
//         );
//         return {
//           'success': false,
//           'message': 'Invalid response format from server.',
//         };
//       }

//       if (response.statusCode == 201 &&
//           responseData != null &&
//           responseData['status'] == 'success') {
//         final String? token = responseData['access_token'] as String?;
//         final Map<String, dynamic>? userData =
//             responseData['user'] as Map<String, dynamic>?;
//         final String? userName = userData?['name'] as String?;
//         final int? userId = userData?['id'] as int?;

//         if (token != null && userName != null && userId != null) {
//           await _tokenService.saveTokenAndUserDetails(token, userName, userId);
//           debugPrint(
//             'AuthService Register: Registration successful. Token and user details saved.',
//           );
//           return {
//             'success': true,
//             'data': responseData,
//           }; // Kembalikan semua responseData asli
//         } else {
//           debugPrint(
//             'AuthService Register: Success status from API but missing token/user data.',
//           );
//           return {
//             'success': false,
//             'message': 'Registration response from server was incomplete.',
//           };
//         }
//       } else {
//         String message = 'Registration failed.';
//         if (responseData != null && responseData['message'] != null) {
//           message = responseData['message'] as String;
//         } else if (response.reasonPhrase != null &&
//             response.reasonPhrase!.isNotEmpty) {
//           message = response.reasonPhrase!;
//         } else if (responseData != null && responseData['errors'] != null) {
//           final errors = responseData['errors'] as Map<String, dynamic>?;
//           if (errors != null && errors.isNotEmpty) {
//             final firstErrorField = errors.keys.first;
//             final firstErrorMessage =
//                 (errors[firstErrorField] as List<dynamic>?)?.first as String?;
//             if (firstErrorMessage != null) {
//               message = firstErrorMessage;
//             }
//           }
//         }
//         debugPrint(
//           'AuthService Register: Registration failed on server. Status: ${response.statusCode}, Message: $message',
//         );
//         return {
//           'success': false,
//           'message': message,
//           'errors': responseData?['errors'] as Map<String, dynamic>?,
//         };
//       }
//     } catch (error) {
//       debugPrint(
//         'AuthService Register: Exception during registration request: $error',
//       );
//       String errorMessage =
//           'Could not connect or an unexpected error occurred.';
//       if (error is http.ClientException || error is SocketException) {
//         errorMessage =
//             'Failed to connect to the server. Please check your internet connection.';
//       } else if (error is TimeoutException) {
//         errorMessage =
//             'The connection to the server timed out. Please try again.';
//       }
//       return {'success': false, 'message': errorMessage};
//     }
//   }

//   Future<void> logout() async {
//     // Idealnya, kita juga panggil API logout backend untuk invalidate token di server
//     final token = await _tokenService.getToken();
//     if (token != null) {
//       final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
//       try {
//         await http.post(
//           url,
//           headers: {
//             'Accept': 'application/json',
//             'Authorization': 'Bearer $token',
//             ..._ngrokSkipHeader,
//           },
//         );
//         debugPrint('AuthService: Logout API call successful or attempted.');
//       } catch (e) {
//         debugPrint('AuthService: Error calling logout API: $e');
//       }
//     }
//     await _tokenService.deleteTokenAndUserDetails(); // Selalu hapus token lokal
//   }

//   Future<Map<String, dynamic>?> getUserProfile() async {
//     final token = await _tokenService.getToken();
//     if (token == null) {
//       return null; // Tidak ada token, user belum login
//     }
//     final url = Uri.parse('${ApiConfig.baseUrl}/auth/user');
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           ..._ngrokSkipHeader,
//         },
//       );
//       final responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 && responseData['status'] == 'success') {
//         return responseData['user'];
//       } else {
//         // Token mungkin tidak valid lagi di server
//         if (response.statusCode == 401) {
//           await _tokenService
//               .deleteTokenAndUserDetails(); // Hapus token tidak valid
//         }
//         return null;
//       }
//     } catch (e) {
//       debugPrint('AuthService: Error fetching user profile: $e');
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>> generateRvmLoginToken() async {
//     final token = await _tokenService.getToken();
//     if (token == null) {
//       return {'success': false, 'message': 'User not authenticated.'};
//     }
//     final url = Uri.parse('${ApiConfig.baseUrl}/user/generate-rvm-token');
//     try {
//       final response = await http.post(
//         // Ini adalah POST request
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           ..._ngrokSkipHeader,
//         },
//       );
//       final responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 && responseData['status'] == 'success') {
//         return {'success': true, 'data': responseData['data']};
//       } else {
//         return {
//           'success': false,
//           'message': responseData['message'] ?? 'Failed to generate RVM token',
//         };
//       }
//     } catch (e) {
//       debugPrint('AuthService: Error generating RVM token: $e');
//       return {
//         'success': false,
//         'message': 'Could not connect or error occurred.',
//       };
//     }
//   }

//   /// Memeriksa status scan token RVM ke backend.
//   Future<Map<String, dynamic>> checkRvmScanStatus(String rvmLoginToken) async {
//     final token = await _tokenService.getToken();
//     if (token == null) {
//       return {
//         'success': false,
//         'status': 'error',
//         'message': 'User not authenticated.',
//       };
//     }

//     final url = Uri.parse(
//       '${ApiConfig.baseUrl}/user/check-rvm-scan-status?token=$rvmLoginToken',
//     );
//     debugPrint(
//       'AuthService: Checking RVM scan status for token: $rvmLoginToken',
//     );
//     try {
//       final response = await http
//           .get(
//             // Ini adalah GET request
//             url,
//             headers: {
//               'Accept': 'application/json',
//               'Authorization': 'Bearer $token', // User's Sanctum token
//               ..._ngrokSkipHeader,
//             },
//           )
//           .timeout(const Duration(seconds: 10));

//       debugPrint(
//         'AuthService CheckScanStatus: Response Status Code: ${response.statusCode}',
//       );
//       debugPrint(
//         'AuthService CheckScanStatus: Response Body: ${response.body}',
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         // Backend diharapkan mengembalikan:
//         // {'status': 'pending_scan' / 'scanned_and_validated' / 'token_expired_or_invalid'}
//         return {'success': true, ...responseData};
//       } else {
//         return {
//           'success': false,
//           'status': 'error',
//           'message':
//               'Failed to check scan status (HTTP ${response.statusCode})',
//         };
//       }
//     } catch (e) {
//       debugPrint('AuthService: Error checking RVM scan status: $e');
//       return {
//         'success': false,
//         'status': 'error',
//         'message': 'Connection error or timeout checking scan status.',
//       };
//     }
//   }

//   // Future<Map<String, dynamic>> login(String email, String password) async {
//   //   final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
//   //   debugPrint('AuthService: Attempting login for $email to $url');
//   //   try {
//   //     final response = await http
//   //         .post(
//   //           url,
//   //           headers: {
//   //             'Content-Type': 'application/json; charset=UTF-8',
//   //             'Accept': 'application/json',
//   //             ..._ngrokSkipHeader, // Gabungkan header ngrok jika perlu
//   //           },
//   //           body: jsonEncode(<String, String>{
//   //             'email': email,
//   //             'password': password,
//   //           }),
//   //         )
//   //         .timeout(
//   //           const Duration(seconds: 15),
//   //         ); // Tambahkan timeout untuk request

//   //     debugPrint(
//   //       'AuthService Login: Response Status Code: ${response.statusCode}',
//   //     );
//   //     debugPrint('AuthService Login: Response Body: ${response.body}');

//   //     Map<String, dynamic>? responseData;

//   //     try {
//   //       if (response.body.isNotEmpty) {
//   //         responseData = jsonDecode(response.body);
//   //       } else {
//   //         // Jika body kosong tapi status bukan 200, ini masalah
//   //         if (response.statusCode != 200) {
//   //           debugPrint(
//   //             'AuthService Login: Empty response body with non-200 status.',
//   //           );
//   //           return {
//   //             'success': false,
//   //             'message':
//   //                 'Received empty response from server (Status: ${response.statusCode}).',
//   //           };
//   //         }
//   //         // Jika body kosong dan status 200 (jarang terjadi untuk login API), anggap gagal
//   //         responseData = null;
//   //       }
//   //     } catch (e) {
//   //       // jika decode gagal
//   //       debugPrint(
//   //         'AuthService Login: Failed to decode JSON response body: $e',
//   //       );
//   //       return {
//   //         'success': false,
//   //         'message': 'Invalid response format from server.',
//   //       };
//   //     }

//   //     // final responseData = jsonDecode(response.body);
//   //     if (response.statusCode == 200 &&
//   //         responseData != null &&
//   //         responseData['status'] == 'success') {
//   //       // --- PERBAIKAN EKSTRAKSI DATA ---
//   //       final String? token =
//   //           responseData['access_token']
//   //               as String?; // Ambil langsung dari responseData
//   //       final Map<String, dynamic>? userData =
//   //           responseData['user']
//   //               as Map<String, dynamic>?; // Ambil langsung dari responseData
//   //       final String? userName = userData?['name'] as String?;
//   //       final int? userId = userData?['id'] as int?;
//   //       // --- AKHIR PERBAIKAN EKSTRAKSI DATA ---
//   //       if (token != null && userName != null && userId != null) {
//   //         await _tokenService.saveTokenAndUserDetails(token, userName, userId);
//   //         debugPrint(
//   //           'AuthService Login: Login successful. Token and user details saved.',
//   //         );
//   //         // Kembalikan data asli jika sukses
//   //         // return {
//   //         //   'success': true,
//   //         //   'data': responseData['data'],
//   //         // };
//   //         return {
//   //           'success': true,
//   //           'data': {
//   //             // Kita buat struktur 'data' di sini jika diperlukan oleh UI
//   //             'access_token': token,
//   //             'user': userData,
//   //           },
//   //         };
//   //       } else {
//   //         debugPrint(
//   //           'AuthService Login: Success status but missing token/user data in response.',
//   //         );
//   //         return {'success': false, 'message': 'Login response incomplete.'};
//   //       }
//   //     } else {
//   //       // Login gagal atau error lain dari server
//   //       // Login gagal di sisi server atau error lain
//   //       String message = 'Login failed.'; // Default message
//   //       if (responseData != null && responseData['message'] != null) {
//   //         message = responseData['message'] as String;
//   //       } else if (response.reasonPhrase != null &&
//   //           response.reasonPhrase!.isNotEmpty) {
//   //         message = response.reasonPhrase!;
//   //       } else if (responseData != null && responseData['errors'] != null) {
//   //         // Coba ambil pesan error pertama dari validasi
//   //         final errors = responseData['errors'] as Map<String, dynamic>?;
//   //         if (errors != null && errors.isNotEmpty) {
//   //           final firstErrorField = errors.keys.first;
//   //           final firstErrorMessage =
//   //               (errors[firstErrorField] as List<dynamic>?)?.first as String?;
//   //           if (firstErrorMessage != null) {
//   //             message = firstErrorMessage;
//   //           }
//   //         }
//   //       }
//   //       debugPrint(
//   //         'AuthService Login: Login failed on server. Status: ${response.statusCode}, Message: $message',
//   //       );

//   //       return {
//   //         'success': false,
//   //         'message': message,
//   //         'errors': responseData?['errors'] as Map<String, dynamic>?,
//   //       };
//   //     }
//   //     // final String token = responseData['data']['access_token'];
//   //     // final String userName = responseData['data']['user']['name'];
//   //     // final int userId = responseData['data']['user']['id'];
//   //     //   await _tokenService.saveTokenAndUserDetails(
//   //     //     token,
//   //     //     userName,
//   //     //     userId,
//   //     //   ); // Simpan token & user
//   //     //   // Login sukses, kembalikan data termasuk token
//   //     //   return {
//   //     //     'success': true,
//   //     //     'data': responseData, // Berisi access_token, user, dll.
//   //     //   };
//   //     // } else {
//   //     //   // Login gagal atau error lain dari server
//   //     //   debugPrint('AuthService (URL: $url) Login Error');
//   //     //   return {
//   //     //     'success': false,
//   //     //     'message': responseData['message'] ?? 'Login failed',
//   //     //     'errors': responseData['errors'],
//   //     //   };
//   //     // }
//   //   } catch (error) {
//   //     // Error koneksi atau lainnya
//   //     debugPrint('AuthService Login: Exception during login request: $error');
//   //     String errorMessage =
//   //         'Could not connect to the server or an unexpected error occurred.';
//   //     if (error is http.ClientException ||
//   //         error is TimeoutException ||
//   //         error is SocketException) {
//   //       errorMessage =
//   //           'An unknown error occurred during login. Please check your internet connection.';
//   //     }
//   //     // Fallback
//   //     return {'success': false, 'message': errorMessage};
//   //   }
//   // }

//   // Future<Map<String, dynamic>> register({
//   //   required String name,
//   //   required String email,
//   //   required String password,
//   //   required String passwordConfirmation,
//   // }) async {
//   //   final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
//   //   debugPrint('AuthService: Attempting registration for $email to $url');
//   //   try {
//   //     final response = await http
//   //         .post(
//   //           url,
//   //           headers: {
//   //             'Content-Type': 'application/json; charset=UTF-8',
//   //             'Accept': 'application/json',
//   //             ..._ngrokSkipHeader,
//   //           },
//   //           body: jsonEncode(<String, String>{
//   //             'name': name,
//   //             'email': email,
//   //             'password': password,
//   //             'password_confirmation': passwordConfirmation,
//   //           }),
//   //         )
//   //         .timeout(const Duration(seconds: 15));

//   //     debugPrint(
//   //       'AuthService Register: Response Status Code: ${response.statusCode}',
//   //     );
//   //     debugPrint('AuthService Register: Response Body: ${response.body}');

//   //     Map<String, dynamic>? responseData;
//   //     try {
//   //       if (response.body.isNotEmpty) {
//   //         responseData = jsonDecode(response.body);
//   //       } else {
//   //         if (response.statusCode != 201) {
//   //           // Status 201 untuk register sukses
//   //           debugPrint(
//   //             'AuthService Register: Empty response body with non-201 status.',
//   //           );
//   //           return {
//   //             'success': false,
//   //             'message':
//   //                 'Received empty response from server (Status: ${response.statusCode}).',
//   //           };
//   //         }
//   //         responseData = null;
//   //       }
//   //     } catch (e) {
//   //       debugPrint(
//   //         'AuthService Register: Failed to decode JSON response body: $e',
//   //       );
//   //       return {
//   //         'success': false,
//   //         'message': 'Invalid response format from server.',
//   //       };
//   //     }

//   //     if (response.statusCode == 201 &&
//   //         responseData != null &&
//   //         responseData['status'] == 'success') {
//   //       final String? token = responseData['access_token'] as String?;
//   //       final Map<String, dynamic>? userData =
//   //           responseData['user'] as Map<String, dynamic>?;
//   //       final String? userName = userData?['name'] as String?;
//   //       final int? userId = userData?['id'] as int?;

//   //       if (token != null && userName != null && userId != null) {
//   //         await _tokenService.saveTokenAndUserDetails(token, userName, userId);
//   //         debugPrint(
//   //           'AuthService Register: Registration successful. Token and user details saved.',
//   //         );
//   //         return {
//   //           'success': true,
//   //           'data': responseData,
//   //         }; // Kembalikan semua responseData asli
//   //       } else {
//   //         debugPrint(
//   //           'AuthService Register: Success status from API but missing token/user data.',
//   //         );
//   //         return {
//   //           'success': false,
//   //           'message': 'Registration response from server was incomplete.',
//   //         };
//   //       }
//   //     } else {
//   //       String message = 'Registration failed.';
//   //       if (responseData != null && responseData['message'] != null) {
//   //         message = responseData['message'] as String;
//   //       } else if (response.reasonPhrase != null &&
//   //           response.reasonPhrase!.isNotEmpty) {
//   //         message = response.reasonPhrase!;
//   //       } else if (responseData != null && responseData['errors'] != null) {
//   //         final errors = responseData['errors'] as Map<String, dynamic>?;
//   //         if (errors != null && errors.isNotEmpty) {
//   //           final firstErrorField = errors.keys.first;
//   //           final firstErrorMessage =
//   //               (errors[firstErrorField] as List<dynamic>?)?.first as String?;
//   //           if (firstErrorMessage != null) {
//   //             message = firstErrorMessage;
//   //           }
//   //         }
//   //       }
//   //       debugPrint(
//   //         'AuthService Register: Registration failed on server. Status: ${response.statusCode}, Message: $message',
//   //       );
//   //       return {
//   //         'success': false,
//   //         'message': message,
//   //         'errors': responseData?['errors'] as Map<String, dynamic>?,
//   //       };
//   //     }
//   //   } catch (error) {
//   //     debugPrint(
//   //       'AuthService Register: Exception during registration request: $error',
//   //     );
//   //     String errorMessage =
//   //         'Could not connect or an unexpected error occurred.';
//   //     if (error is http.ClientException || error is SocketException) {
//   //       errorMessage =
//   //           'Failed to connect to the server. Please check your internet connection.';
//   //     } else if (error is TimeoutException) {
//   //       errorMessage =
//   //           'The connection to the server timed out. Please try again.';
//   //     }
//   //     return {'success': false, 'message': errorMessage};
//   //   }
//   //   // final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
//   //   // debugPrint('AuthService: Attempting registration for $email to $url');
//   //   // try {
//   //   //   final response = await http
//   //   //       .post(
//   //   //         url,
//   //   //         headers: {
//   //   //           'Content-Type': 'application/json; charset=UTF-8',
//   //   //           'Accept': 'application/json',
//   //   //           ..._ngrokSkipHeader, // Gabungkan header ngrok jika perlu
//   //   //         },
//   //   //         body: jsonEncode(<String, String>{
//   //   //           'name': name,
//   //   //           'email': email,
//   //   //           'password': password,
//   //   //           'password_confirmation': passwordConfirmation,
//   //   //         }),
//   //   //       )
//   //   //       .timeout(const Duration(seconds: 15));

//   //   //   debugPrint(
//   //   //     'AuthService Register: Response Status Code: ${response.statusCode}',
//   //   //   );
//   //   //   debugPrint('AuthService Register: Response Body: ${response.body}');

//   //   //   final responseData = jsonDecode(response.body);
//   //   //   if (response.statusCode == 201 && responseData['status'] == 'success') {
//   //   //     final String token = responseData['data']['access_token'];
//   //   //     final String userName = responseData['data']['user']['name'];
//   //   //     final int userId = responseData['data']['user']['id'];
//   //   //     await _tokenService.saveTokenAndUserDetails(
//   //   //       token,
//   //   //       userName,
//   //   //       userId,
//   //   //     ); // Simpan token & user
//   //   //     return {'success': true, 'data': responseData};
//   //   //   } else {
//   //   //     return {
//   //   //       'success': false,
//   //   //       'message': responseData['message'] ?? 'Registration failed',
//   //   //       'errors': responseData['errors'],
//   //   //     };
//   //   //   }
//   //   // } catch (error) {
//   //   //   debugPrint('AuthService Register Error: $error');
//   //   //   return {
//   //   //     'success': false,
//   //   //     'message': 'Registration failed due to an unexpected error.',
//   //   //   }; // Fallback
//   //   // }
//   // }

//   // // TODO: Tambahkan metode untuk logout, userProfile, generateRvmToken, googleTokenSignIn nanti
//   // Future<void> logout() async {
//   //   // Idealnya, kita juga panggil API logout backend untuk invalidate token di server
//   //   final token = await _tokenService.getToken();
//   //   if (token != null) {
//   //     final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
//   //     try {
//   //       await http.post(
//   //         url,
//   //         headers: {
//   //           'Accept': 'application/json',
//   //           'Authorization': 'Bearer $token',
//   //           ..._ngrokSkipHeader,
//   //         },
//   //       );
//   //       debugPrint('AuthService: Logout API call successful or attempted.');
//   //     } catch (e) {
//   //       debugPrint('AuthService: Error calling logout API: $e');
//   //     }
//   //   }
//   //   await _tokenService.deleteTokenAndUserDetails(); // Selalu hapus token lokal
//   // }

//   // Future<Map<String, dynamic>?> getUserProfile() async {
//   //   final token = await _tokenService.getToken();
//   //   if (token == null) {
//   //     return null; // Tidak ada token, user belum login
//   //   }
//   //   final url = Uri.parse('${ApiConfig.baseUrl}/auth/user');
//   //   try {
//   //     final response = await http.get(
//   //       url,
//   //       headers: {
//   //         'Accept': 'application/json',
//   //         'Authorization': 'Bearer $token',
//   //         ..._ngrokSkipHeader,
//   //       },
//   //     );
//   //     final responseData = jsonDecode(response.body);
//   //     if (response.statusCode == 200 && responseData['status'] == 'success') {
//   //       return responseData['user'];
//   //     } else {
//   //       // Token mungkin tidak valid lagi di server
//   //       if (response.statusCode == 401) {
//   //         await _tokenService
//   //             .deleteTokenAndUserDetails(); // Hapus token tidak valid
//   //       }
//   //       return null;
//   //     }
//   //   } catch (e) {
//   //     debugPrint('AuthService: Error fetching user profile: $e');
//   //     return null;
//   //   }
//   // }

//   // Future<Map<String, dynamic>> generateRvmLoginToken() async {
//   //   final token = await _tokenService.getToken();
//   //   if (token == null) {
//   //     return {'success': false, 'message': 'User not authenticated.'};
//   //   }
//   //   final url = Uri.parse('${ApiConfig.baseUrl}/user/generate-rvm-token');
//   //   try {
//   //     final response = await http.post(
//   //       // Ini adalah POST request
//   //       url,
//   //       headers: {
//   //         'Accept': 'application/json',
//   //         'Authorization': 'Bearer $token',
//   //         ..._ngrokSkipHeader,
//   //       },
//   //     );
//   //     final responseData = jsonDecode(response.body);
//   //     if (response.statusCode == 200 && responseData['status'] == 'success') {
//   //       return {'success': true, 'data': responseData['data']};
//   //     } else {
//   //       return {
//   //         'success': false,
//   //         'message': responseData['message'] ?? 'Failed to generate RVM token',
//   //       };
//   //     }
//   //   } catch (e) {
//   //     debugPrint('AuthService: Error generating RVM token: $e');
//   //     return {
//   //       'success': false,
//   //       'message': 'Could not connect or error occurred.',
//   //     };
//   //   }
//   // }
// }
