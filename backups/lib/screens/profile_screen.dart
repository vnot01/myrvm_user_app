// // lib/screens/profile_screen.dart
// import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // Untuk SystemNavigator jika diperlukan
// import '../services/auth_service.dart.backup';
// import '../services/token_service.dart'; // Untuk mendapatkan detail user jika disimpan
// import 'auth/login_screen.dart'; // Untuk navigasi setelah logout

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final AuthService _authService = AuthService();
//   final TokenService _tokenService =
//       TokenService(); // Untuk mengambil nama/id jika perlu

//   Map<String, dynamic>? _userData; // Untuk menyimpan data profil dari API
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }

//   Future<void> _fetchUserProfile() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final userProfile = await _authService.getUserProfile();
//       if (mounted) {
//         if (userProfile != null) {
//           debugPrint(
//             "ProfileScreen _fetchUserProfile: userProfile type: ${userProfile.runtimeType}",
//           );
//           debugPrint(
//             "ProfileScreen _fetchUserProfile: userProfile data: $userProfile",
//           );
//           setState(() {
//             _userData = userProfile; // Pastikan ini adalah Map<String, dynamic>
//             _isLoading = false;
//           });
//         } else {
//           // Kemungkinan token tidak valid lagi, paksa logout
//           setState(() {
//             _isLoading = false;
//             _errorMessage =
//                 "Gagal mengambil data profil. Sesi mungkin berakhir.";
//           });
//           await _forceLogout();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "Terjadi kesalahan: ${e.toString()}";
//         });
//       }
//       debugPrint("Error fetching profile: $e");
//     }
//   }

//   Future<void> _forceLogout() async {
//     await _authService.logout();
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//         (Route<dynamic> route) => false,
//       );
//     }
//   }

//   Future<void> _logout() async {
//     final bool? confirmLogout = await showDialog<bool>(
//       context: context,
//       // User harus memilih salah
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         // Konteks untuk dialog
//         return AlertDialog(
//           title: const Text('Konfirmasi Logout'),
//           content: const Text('Apakah Anda yakin ingin logout dari aplikasi?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Tidak'),
//               onPressed: () {
//                 Navigator.of(
//                   dialogContext,
//                 ).pop(false); // Tutup dialog dan kembalikan false
//               },
//             ),
//             TextButton(
//               child: const Text('Ya, Logout'),
//               onPressed: () {
//                 Navigator.of(
//                   dialogContext,
//                 ).pop(true); // Tutup dialog dan kembalikan true
//               },
//             ),
//           ],
//         );
//       },
//     ); // Akhir dari showDialog

//     // Hanya lanjutkan jika pengguna mengkonfirmasi (menekan "Ya, Logout")
//     if (confirmLogout == true) {
//       // Pengecekan eksplisit ke true lebih aman
//       await _authService.logout();
//       if (mounted) {
//         // Selalu cek 'mounted' sebelum memanggil Navigator dalam async gap
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     } else {
//       debugPrint("Logout dibatalkan oleh pengguna.");
//     }
//   }

//   Widget _buildProfileDetail(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Expanded(
//             child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint(
//       "ProfileScreen build() called. _isLoading: $_isLoading, _errorMessage: $_errorMessage",
//     );
//     if (_userData != null) {
//       debugPrint("ProfileScreen _userData: $_userData");
//     } else {
//       debugPrint("ProfileScreen _userData is NULL");
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profil Pengguna'),
//         // Tombol back akan muncul otomatis karena layar ini di-push
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _errorMessage != null
//               ? Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red, fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               )
//               : _userData != null
//               ? RefreshIndicator(
//                 // Untuk fitur pull-to-refresh
//                 onRefresh: _fetchUserProfile,
//                 child: ListView(
//                   // Ganti dengan ListView agar bisa scroll jika konten banyak
//                   padding: const EdgeInsets.all(24.0),

//                   children: <Widget>[
//                     // CircleAvatar(
//                     //   radius: 50,
//                     //   backgroundImage:
//                     //       _userData!['avatar'] != null
//                     //           ? NetworkImage(_userData!['avatar'])
//                     //           : null, // Placeholder jika tidak ada avatar
//                     //   child:
//                     //       _userData!['avatar'] == null
//                     //           ? const Icon(Icons.person, size: 50)
//                     //           : null,
//                     // ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "Nama dari _userData: ${_userData?['name'] ?? 'N/A - Nama'}",
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     Text(
//                       "Email dari _userData: ${_userData?['email'] ?? 'N/A - Email'}",
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     // const SizedBox(height: 20),
//                     // _buildProfileDetail('Nama', _userData!['name']),
//                     // _buildProfileDetail('Email', _userData!['email']),
//                     // _buildProfileDetail(
//                     //   'Poin',
//                     //   _userData!['points']?.toString() ?? '0',
//                     // ),
//                     // _buildProfileDetail('Role', _userData!['role']),
//                     // _buildProfileDetail(
//                     //   'No. Telepon',
//                     //   _userData!['phone_number'],
//                     // ),
//                     // _buildProfileDetail(
//                     //   'Kewarganegaraan',
//                     //   _userData!['citizenship'],
//                     // ),
//                     // _buildProfileDetail(
//                     //   'Tipe Identitas',
//                     //   _userData!['identity_type'],
//                     // ),
//                     // _buildProfileDetail(
//                     //   'No. Identitas',
//                     //   _userData!['identity_number'],
//                     // ),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.logout),
//                       label: const Text('Logout'),
//                       onPressed: _logout,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : const Center(child: Text('Tidak ada data profil pengguna.')),
//     );
//   }
// }
