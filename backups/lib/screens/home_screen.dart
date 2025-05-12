// // lib/screens/history_screen.dart
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Beranda RVM")),
//       body: const Center(
//         child: Text("Halaman Beranda RVM Akan Tampil Di Sini"),
//       ),
//     );
//   }
// }

// // // lib/screens/home_screen.dart
// // import 'dart:async'; // Untuk Timer
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // Untuk SystemNavigator dan (nantinya) ScreenBrightness
// // // Untuk screen_brightness:
// // import 'package:screen_brightness/screen_brightness.dart';
// // import 'package:qr_flutter/qr_flutter.dart'; // Untuk menampilkan QR Code
// // import '../services/auth_service.dart';
// // import '../services/token_service.dart'; // Jika perlu mengambil detail user untuk sapaan
// // import 'auth/login_screen.dart'; // Untuk navigasi setelah logout
// // import 'profile_screen.dart'; // Nanti kita buat ProfileScreen
// // // import 'package:flutter/foundation.dart'; // Untuk debugPrint

// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   final AuthService _authService = AuthService();
// //   // Opsional, jika ingin ambil nama user
// //   final TokenService _tokenService = TokenService();
// //   // Menyimpan data token QR yang aktif untuk ditampilkan
// //   String? _activeRvmToken;
// //   Timer? _qrTokenTimer; // Timer untuk masa berlaku QR
// //   // Waktu sisa default untuk QR
// //   Duration _timeLeft = const Duration(minutes: 5);
// //   String? _rvmTokenData;
// //   bool _isGeneratingToken = false; // Status loading saat API dipanggil
// //   // Untuk kontrol kecerahan layar (opsional, implementasi nanti)
// //   ScreenBrightness _screenBrightness = ScreenBrightness();
// //   //// Default, akan diupdate dengan brightness asli
// //   double _originalBrightness = 0.5;
// //   // Untuk memastikan hanya tanya sekali per sesi app
// //   bool _brightnessPermissionAsked = false;
// //   bool _brightnessPermissionGranted = false;
// //   String? _userName;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // _loadUserName(); // Jika ingin menampilkan nama user
// //     _getInitialBrightness(); // Jika ingin langsung dapat brightness awal
// //   }

// //   Future<void> _getInitialBrightness() async {
// //     try {
// //       _originalBrightness = await _screenBrightness.current;
// //     } catch (e) {
// //       debugPrint("HomeScreen: Gagal mendapatkan kecerahan awal: $e");
// //       _originalBrightness = 0.5; // Fallback
// //     }
// //   }

// //   void _startOrResetQrTimer() {
// //     // batalkan Timer Sebelumnya Jika ada.
// //     _qrTokenTimer?.cancel();
// //     setState(() {
// //       _timeLeft = const Duration(minutes: 5);
// //     });
// //     _qrTokenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       // Jika widget sudah tidak ada di tree, batalkan timer
// //       if (!mounted) {
// //         timer.cancel();
// //         return;
// //       }
// //       if (_timeLeft.inSeconds == 0) {
// //         timer.cancel();
// //         setState(() {
// //           // Token tidak valid lagi. kembali ke Placeholder
// //           _activeRvmToken = null;
// //           debugPrint("HomeScreen: Timer QR Code Habis.");
// //         });
// //       } else {
// //         setState(() {
// //           _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
// //         });
// //       }
// //     });
// //   }

// //   Future<void> _requestBrightnessPermissionAndSet() async {
// //     // Untuk sekarang, kita anggap izin diberikan atau tidak diimplementasikan dulu
// //     // Jika sudah pernah ditanya dan diizinkan, langsung set
// //     if (_brightnessPermissionGranted) {
// //       try {
// //         _originalBrightness = await _screenBrightness.current;
// //         await _screenBrightness.setScreenBrightness(1.0); // Maksimum
// //         debugPrint("HomeScreen: Kecerahan layar dimaksimalkan.");
// //       } catch (e) {
// //         debugPrint("HomeScreen: Gagal set kecerahan: $e");
// //       }
// //       return;
// //     }

// //     // Jika belum pernah ditanya di sesi ini
// //     if (!_brightnessPermissionAsked && mounted) {
// //       _brightnessPermissionAsked = true; // Tandai sudah pernah ditanya
// //       final bool? confirm = await showDialog<bool>(
// //         context: context,
// //         builder: (BuildContext dialogContext) {
// //           return AlertDialog(
// //             title: const Text('Optimalkan Scan QR'),
// //             content: const Text(
// //               'Untuk pembacaan QR yang lebih baik oleh mesin, izinkan aplikasi meningkatkan kecerahan layar Anda sementara?',
// //             ),
// //             actions: <Widget>[
// //               TextButton(
// //                 onPressed: () => Navigator.of(dialogContext).pop(false),
// //                 child: const Text('Lain Kali'),
// //               ),
// //               TextButton(
// //                 onPressed: () => Navigator.of(dialogContext).pop(true),
// //                 child: const Text('Izinkan'),
// //               ),
// //             ],
// //           );
// //         },
// //       );
// //       if (confirm == true && mounted) {
// //         _brightnessPermissionGranted = true;
// //         try {
// //           _originalBrightness = await _screenBrightness.current;
// //           await _screenBrightness.setScreenBrightness(1.0);
// //           debugPrint("HomeScreen: Kecerahan layar dimaksimalkan setelah izin.");
// //         } catch (e) {
// //           debugPrint("HomeScreen: Gagal set kecerahan setelah izin: $e");
// //         }
// //       } else {
// //         debugPrint("HomeScreen: User tidak mengizinkan perubahan kecerahan.");
// //       }
// //     } else if (_brightnessPermissionGranted && mounted) {
// //       // Jika sudah diizinkan sebelumnya
// //       try {
// //         _originalBrightness = await _screenBrightness.current;
// //         await _screenBrightness.setScreenBrightness(1.0);
// //         debugPrint(
// //           "HomeScreen: Kecerahan layar dimaksimalkan (izin sudah ada).",
// //         );
// //       } catch (e) {
// //         debugPrint("HomeScreen: Gagal set kecerahan (izin sudah ada): $e");
// //       }
// //     }
// //   }

// //   Future<void> _resetBrightness() async {
// //     if (_brightnessPermissionGranted) {
// //       // Hanya reset jika sebelumnya kita yang ubah
// //       try {
// //         await _screenBrightness.setScreenBrightness(_originalBrightness);
// //         debugPrint("HomeScreen: Kecerahan layar dikembalikan ke semula.");
// //       } catch (e) {
// //         debugPrint("HomeScreen: Gagal mengembalikan kecerahan: $e");
// //       }
// //       // Reset status izin agar ditanya lagi di sesi berikutnya jika perlu
// //       // atau simpan pilihan user di shared_preferences jika ada "jangan tanya lagi"
// //       // Atau kelola ini dengan lebih baik
// //       _brightnessPermissionGranted = false;
// //     }
// //   }

// //   Future<void> _onQrFabPressed() async {
// //     if (_isGeneratingToken) return;
// //     // Minta izin dan set brightness
// //     await _requestBrightnessPermissionAndSet();

// //     setState(() {
// //       _isGeneratingToken = true;
// //     });

// //     final result = await _authService.generateRvmLoginToken();

// //     if (mounted) {
// //       if (result['success']) {
// //         // Akses lebih aman
// //         final newTokenData = result['data']?['rvm_login_token'] as String?;
// //         if (newTokenData != null) {
// //           setState(() {
// //             _activeRvmToken = newTokenData;
// //             _isGeneratingToken = false;
// //           });
// //           _startOrResetQrTimer();
// //           debugPrint('HomeScreen: RVM Token Generated: $_activeRvmToken');
// //         } else {
// //           setState(() {
// //             _isGeneratingToken = false;
// //           });
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('Gagal mendapatkan data token dari server.'),
// //             ),
// //           );
// //         }
// //       } else {
// //         setState(() {
// //           _isGeneratingToken = false;
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(result['message'] ?? 'Gagal generate token RVM'),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   Future<void> _generateAndDisplayToken() async {
// //     if (_isGeneratingToken) return;
// //     setState(() {
// //       _isGeneratingToken = true;
// //     });
// //     final result = await _authService.generateRvmLoginToken();

// //     if (mounted) {
// //       if (result['success']) {
// //         final newTokenData = result['data']['rvm_login_token'] as String?;
// //         if (newTokenData != null) {
// //           setState(() {
// //             _activeRvmToken = newTokenData;
// //             _isGeneratingToken = false;
// //           });
// //           _startOrResetQrTimer();
// //           debugPrint('HomeScreen RVM Token Generated: $_activeRvmToken');
// //         } else {
// //           setState(() {
// //             _isGeneratingToken = false;
// //           });
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Gagal Mendapat token Dari Server.')),
// //           );
// //         }
// //       } else {
// //         setState(() {
// //           _isGeneratingToken = false;
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(result['message'] ?? 'Gagal Generate token RVM'),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   // Future<void> _generateAndDisplayToken() async {
// //   //   if (_isGeneratingToken) return; // Hindari panggilan ganda

// //   //   setState(() {
// //   //     _isGeneratingToken = true;
// //   //   });

// //   //   final result = await _authService.generateRvmLoginToken();

// //   //   if (mounted) {
// //   //     if (result['success']) {
// //   //       final newTokenData = result['data']['rvm_login_token'] as String?;
// //   //       if (newTokenData != null) {
// //   //         setState(() {
// //   //           _activeRvmToken = newTokenData;
// //   //           _isGeneratingToken = false;
// //   //         });
// //   //         _startOrResetQrTimer(); // Mulai timer untuk token baru
// //   //         debugPrint('HomeScreen: RVM Token Generated: $_activeRvmToken');
// //   //       } else {
// //   //         setState(() {
// //   //           _isGeneratingToken = false;
// //   //         });
// //   //         ScaffoldMessenger.of(context).showSnackBar(
// //   //           const SnackBar(
// //   //             content: Text('Gagal mendapatkan data token dari server.'),
// //   //           ),
// //   //         );
// //   //       }
// //   //     } else {
// //   //       setState(() {
// //   //         _isGeneratingToken = false;
// //   //       });
// //   //       ScaffoldMessenger.of(context).showSnackBar(
// //   //         SnackBar(
// //   //           content: Text(result['message'] ?? 'Gagal generate token RVM'),
// //   //         ),
// //   //       );
// //   //     }
// //   //   }
// //   // }

// //   // Future<void> _generateToken() async {
// //   //   setState(() {
// //   //     _isGeneratingToken = true;
// //   //     _rvmTokenData = null; // Reset token lama
// //   //   });
// //   //   final result = await _authService.generateRvmLoginToken();
// //   //   if (mounted) {
// //   //     setState(() {
// //   //       _isGeneratingToken = false;
// //   //       if (result['success']) {
// //   //         _rvmTokenData = result['data']['rvm_login_token'];
// //   //         debugPrint('HomeScreen: RVM Token Generated: $_rvmTokenData');
// //   //       } else {
// //   //         ScaffoldMessenger.of(context).showSnackBar(
// //   //           SnackBar(
// //   //             content: Text(result['message'] ?? 'Gagal generate token RVM'),
// //   //           ),
// //   //         );
// //   //       }
// //   //     });
// //   //   }
// //   // }

// //   Future<void> _logout() async {
// //     final bool? confirmLogout = await showDialog<bool>(
// //       context: context,
// //       // User harus memilih salah
// //       barrierDismissible: false,
// //       builder: (BuildContext dialogContext) {
// //         // Konteks untuk dialog
// //         return AlertDialog(
// //           title: const Text('Konfirmasi Logout'),
// //           content: const Text('Apakah Anda yakin ingin logout dari aplikasi?'),
// //           actions: <Widget>[
// //             TextButton(
// //               child: const Text('Tidak'),
// //               onPressed: () {
// //                 Navigator.of(
// //                   dialogContext,
// //                 ).pop(false); // Tutup dialog dan kembalikan false
// //               },
// //             ),
// //             TextButton(
// //               child: const Text('Ya, Logout'),
// //               onPressed: () {
// //                 Navigator.of(
// //                   dialogContext,
// //                 ).pop(true); // Tutup dialog dan kembalikan true
// //               },
// //             ),
// //           ],
// //         );
// //       },
// //     ); // Akhir dari showDialog

// //     // Hanya lanjutkan jika pengguna mengkonfirmasi (menekan "Ya, Logout")
// //     if (confirmLogout == true) {
// //       // Pengecekan eksplisit ke true lebih aman
// //       await _authService.logout();
// //       if (mounted) {
// //         // Selalu cek 'mounted' sebelum memanggil Navigator dalam async gap
// //         Navigator.of(context).pushAndRemoveUntil(
// //           MaterialPageRoute(builder: (context) => const LoginScreen()),
// //           (Route<dynamic> route) => false,
// //         );
// //       }
// //     } else {
// //       debugPrint("Logout dibatalkan oleh pengguna.");
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _qrTokenTimer?.cancel(); // Pastikan timer dibatalkan saat widget di-dispose
// //     super.dispose();
// //   }

// //   Widget _buildQrArea() {
// //     // (Yang menampilkan QrImageView atau Placeholder berdasarkan _activeRvmToken dan _timeLeft)
// //     // Pastikan teks "Kode berlaku:" menggunakan _timeLeft dari state.
// //     if (_isGeneratingToken) {
// //       // Beri tinggi agar tidak kolaps
// //       return const Center(heightFactor: 5, child: CircularProgressIndicator());
// //     }
// //     if (_activeRvmToken != null && _timeLeft.inSeconds > 0) {
// //       return Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Text(
// //             "Scan di Mesin RVM:",
// //             style: Theme.of(context).textTheme.titleMedium,
// //           ),
// //           const SizedBox(height: 10),
// //           QrImageView(
// //             data: _activeRvmToken!,
// //             version: QrVersions.auto,
// //             size: 200.0,
// //             gapless: false,
// //           ),
// //           const SizedBox(height: 10),
// //           Text(
// //             "Kode berlaku: ${_timeLeft.inMinutes.toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}",
// //             style: const TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.orangeAccent,
// //             ),
// //           ),
// //         ],
// //       );
// //     } else {
// //       // Placeholder saat tidak ada QR aktif atau setelah timer habis
// //       return Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(Icons.qr_code_2_outlined, size: 100, color: Colors.grey[400]),
// //           const SizedBox(height: 10),
// //           const Text(
// //             "Tekan tombol 'Scan Saya' untuk menampilkan kode deposit.",
// //             textAlign: TextAlign.center,
// //             style: TextStyle(fontSize: 16, color: Colors.grey),
// //           ),
// //         ],
// //       );
// //     }
// //   }

// //   String get _fabLabel {
// //     if (_isGeneratingToken) {
// //       return "MEMPROSES...";
// //     }
// //     if (_activeRvmToken != null && _timeLeft.inSeconds > 0) {
// //       return "${_timeLeft.inMinutes.toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}";
// //     }
// //     return "SCAN SAYA";
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return PopScope(
// //       // Kita akan handle pop secara manual dengan dialog
// //       canPop: false,
// //       onPopInvokedWithResult: (bool didPop, dynamic result) async {
// //         // Seharusnya tidak terjadi jika canPop false
// //         if (didPop) return;
// //         debugPrint("PopScope di HomeScreen dicegah.");
// //         final bool? shouldExit = await showDialog<bool>(
// //           context: context,
// //           builder:
// //               (context) => AlertDialog(
// //                 title: const Text('Keluar Aplikasi?'),
// //                 content: const Text(
// //                   'Apakah Anda yakin ingin keluar dari aplikasi RVM?',
// //                 ),
// //                 actions: <Widget>[
// //                   TextButton(
// //                     onPressed: () => Navigator.of(context).pop(false), // Tidak
// //                     child: const Text('Tidak'),
// //                   ),
// //                   TextButton(
// //                     onPressed: () => Navigator.of(context).pop(true), // Ya
// //                     child: const Text('Ya'),
// //                   ),
// //                 ],
// //               ),
// //         );
// //         if (shouldExit ?? false) {
// //           SystemNavigator.pop();
// //         }
// //       },
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('RVM Home'), // Mungkin tambahkan _userName di sini
// //           automaticallyImplyLeading:
// //               false, // Pastikan tidak ada tombol back otomatis
// //           actions: [
// //             IconButton(
// //               icon: const Icon(Icons.person_outline), // Ganti ikon jika mau
// //               tooltip: 'Profil',
// //               onPressed: () {
// //                 // --- Navigasi ke ProfileScreen ---
// //                 Navigator.of(context).push(
// //                   MaterialPageRoute(
// //                     builder: (context) => const ProfileScreen(),
// //                   ),
// //                 );
// //                 // --- Akhir Navigasi ---
// //               },
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.logout),
// //               tooltip: 'Logout',
// //               onPressed: _logout,
// //             ),
// //           ],
// //         ),
// //         body: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               // Agar ada ruang untuk FAB
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: <Widget>[
// //                 // Anda bisa letakkan info user atau poin di sini jika mau
// //                 const Text(
// //                   'Selamat Datang!', // Mungkin tambahkan nama user di sini
// //                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 20),
// //                 // Area untuk menampilkan QR Code atau placeholder
// //                 Container(
// //                   padding: const EdgeInsets.all(16.0),
// //                   // Beri tinggi minimal
// //                   constraints: const BoxConstraints(minHeight: 280),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(12.0),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.grey.withValues(alpha: 0.2),
// //                         spreadRadius: 1,
// //                         blurRadius: 8,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ],
// //                   ),
// //                   // Panggil fungsi untuk membangun konten area QR
// //                   child: _buildQrArea(),
// //                 ),
// //                 // Jarak sebelum FAB jika FAB tidak docked
// //                 const SizedBox(height: 20),
// //                 // Tombol Generate/Timer tidak lagi di sini, pindah ke FAB
// //               ],
// //             ),
// //           ),
// //         ),
// //         // Posisi FAB
// //         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// //         // Beri padding bawah untuk FAB
// //         floatingActionButton: Padding(
// //           padding: const EdgeInsets.only(bottom: 16.0),
// //           child: FloatingActionButton.extended(
// //             onPressed:
// //                 _isGeneratingToken ||
// //                         (_activeRvmToken != null && _timeLeft.inSeconds > 0)
// //                     ? null // Disable jika sedang generate atau timer aktif
// //                     : _onQrFabPressed, // Hanya panggil jika tidak ada token aktif & tidak sedang generate
// //             icon: const Icon(Icons.qr_code_scanner),
// //             // Menggunakan getter untuk label dinamis
// //             label: Text(_fabLabel),
// //             // Ubah warna FAB saat menjadi timer
// //             backgroundColor:
// //                 (_activeRvmToken != null && _timeLeft.inSeconds > 0)
// //                     ? Colors.orangeAccent
// //                     : Theme.of(context).colorScheme.primary,
// //           ),
// //         ),

// //         bottomNavigationBar: BottomAppBar(
// //           shape: const CircularNotchedRectangle(),
// //           notchMargin: 8.0,
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: <Widget>[
// //               IconButton(
// //                 icon: const Icon(Icons.home_outlined),
// //                 onPressed: () {
// //                   debugPrint("Home Tapped");
// //                 },
// //                 tooltip: "Home",
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.bar_chart_outlined),
// //                 onPressed: () {
// //                   debugPrint("Statistik Tapped");
// //                 },
// //                 tooltip: "Statistik",
// //               ),
// //               const SizedBox(width: 48), // Ruang untuk FAB
// //               IconButton(
// //                 icon: const Icon(Icons.history_outlined),
// //                 onPressed: () {
// //                   debugPrint("Riwayat Tapped");
// //                 },
// //                 tooltip: "Riwayat",
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.person_outline),
// //                 tooltip: "Profil",
// //                 onPressed: () {
// //                   Navigator.of(context).push(
// //                     MaterialPageRoute(
// //                       builder: (context) => const ProfileScreen(),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
