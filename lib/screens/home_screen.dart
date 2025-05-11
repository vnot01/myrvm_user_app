// lib/screens/home_screen.dart
import 'dart:async'; // Untuk Timer
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import qr_flutter
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart'; // Untuk navigasi setelah logout
import 'profile_screen.dart'; // Nanti kita buat ProfileScreen
// import 'package:flutter/foundation.dart'; // Untuk debugPrint

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _activeRvmToken; // Token QR yang sedang aktif
  Timer? _qrTokenTimer; // Timer untuk masa berlaku QR
  Duration _timeLeft = const Duration(minutes: 5); // Default
  String? _rvmTokenData;
  bool _isGeneratingToken = false;
  // String? _userName;
  // final TokenService _tokenService = TokenService();

  void _startOrResetQrTimer() {
    _qrTokenTimer?.cancel(); // batalkan Timer Sebelumnya Jika ada.
    setState(() {
      _timeLeft = const Duration(minutes: 5);
    });
    _qrTokenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _activeRvmToken =
                null; // Token tidak valid lagi. kembali ke Placeholder
            debugPrint("HomeScreen: Timer QR Code Habis.");
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
          });
        } else {
          timer.cancel();
        }
      }
    });
  }

  Future<void> _generateAndDisplayToken() async {
    if (_isGeneratingToken) return;
    setState(() {
      _isGeneratingToken = true;
    });
    final result = await _authService.generateRvmLoginToken();

    if (mounted) {
      if (result['success']) {
        final newTokenData = result['data']['rvm_login_token'] as String?;
        if (newTokenData != null) {
          setState(() {
            _activeRvmToken = newTokenData;
            _isGeneratingToken = false;
          });
          _startOrResetQrTimer();
          debugPrint('HomeScreen RVM Token Generated: $_activeRvmToken');
        } else {
          setState(() {
            _isGeneratingToken = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal Mendapat token Dari Server.')),
          );
        }
      } else {
        setState(() {
          _isGeneratingToken = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal Generate token RVM'),
          ),
        );
      }
    }
  }

  // Future<void> _generateAndDisplayToken() async {
  //   if (_isGeneratingToken) return; // Hindari panggilan ganda

  //   setState(() {
  //     _isGeneratingToken = true;
  //   });

  //   final result = await _authService.generateRvmLoginToken();

  //   if (mounted) {
  //     if (result['success']) {
  //       final newTokenData = result['data']['rvm_login_token'] as String?;
  //       if (newTokenData != null) {
  //         setState(() {
  //           _activeRvmToken = newTokenData;
  //           _isGeneratingToken = false;
  //         });
  //         _startOrResetQrTimer(); // Mulai timer untuk token baru
  //         debugPrint('HomeScreen: RVM Token Generated: $_activeRvmToken');
  //       } else {
  //         setState(() {
  //           _isGeneratingToken = false;
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Gagal mendapatkan data token dari server.'),
  //           ),
  //         );
  //       }
  //     } else {
  //       setState(() {
  //         _isGeneratingToken = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['message'] ?? 'Gagal generate token RVM'),
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<void> _generateToken() async {
  //   setState(() {
  //     _isGeneratingToken = true;
  //     _rvmTokenData = null; // Reset token lama
  //   });
  //   final result = await _authService.generateRvmLoginToken();
  //   if (mounted) {
  //     setState(() {
  //       _isGeneratingToken = false;
  //       if (result['success']) {
  //         _rvmTokenData = result['data']['rvm_login_token'];
  //         debugPrint('HomeScreen: RVM Token Generated: $_rvmTokenData');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(result['message'] ?? 'Gagal generate token RVM'),
  //           ),
  //         );
  //       }
  //     });
  //   }
  // }

  Future<void> _logout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      // User harus memilih salah
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Konteks untuk dialog
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false); // Tutup dialog dan kembalikan false
              },
            ),
            TextButton(
              child: const Text('Ya, Logout'),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true); // Tutup dialog dan kembalikan true
              },
            ),
          ],
        );
      },
    ); // Akhir dari showDialog

    // Hanya lanjutkan jika pengguna mengkonfirmasi (menekan "Ya, Logout")
    if (confirmLogout == true) {
      // Pengecekan eksplisit ke true lebih aman
      await _authService.logout();
      if (mounted) {
        // Selalu cek 'mounted' sebelum memanggil Navigator dalam async gap
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      debugPrint("Logout dibatalkan oleh pengguna.");
    }
  }

  @override
  void dispose() {
    _qrTokenTimer?.cancel(); // Pastikan timer dibatalkan saat widget di-dispose
    super.dispose();
  }

  Widget _buildQrArea() {
    if (_isGeneratingToken) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_activeRvmToken != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Scan di Mesin RVM:",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          QrImageView(
            data: _activeRvmToken!,
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
          ),
          const SizedBox(height: 10),
          Text(
            "Kode berlaku: ${_timeLeft.inMinutes.toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
        ],
      );
    } else {
      // Placeholder saat tidak ada QR aktif atau setelah timer habis
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 10),
          const Text(
            "Tekan tombol 'Scan Saya' untuk menampilkan kode deposit.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Kita akan handle pop secara manual dengan dialog
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return; // Seharusnya tidak terjadi jika canPop false
        debugPrint("PopScope di HomeScreen dicegah.");
        final bool? shouldExit = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Keluar Aplikasi?'),
                content: const Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi RVM?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Tidak
                    child: const Text('Tidak'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true), // Ya
                    child: const Text('Ya'),
                  ),
                ],
              ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RVM Home'), // Mungkin tambahkan _userName di sini
          automaticallyImplyLeading:
              false, // Pastikan tidak ada tombol back otomatis
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline), // Ganti ikon jika mau
              tooltip: 'Profil',
              onPressed: () {
                // --- Navigasi ke ProfileScreen ---
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                // --- Akhir Navigasi ---
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Agar ada ruang untuk FAB
              children: <Widget>[
                // Anda bisa letakkan info user atau poin di sini jika mau
                const Text(
                  'Selamat Datang!', // Mungkin tambahkan nama user di sini
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Area untuk menampilkan QR Code atau placeholder
                Container(
                  padding: const EdgeInsets.all(16.0),
                  constraints: const BoxConstraints(
                    minHeight: 280,
                  ), // Beri tinggi minimal
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child:
                      _buildQrArea(), // Panggil fungsi untuk membangun konten area QR
                ),
                const SizedBox(
                  height: 20,
                ), // Jarak sebelum FAB jika FAB tidak docked
              ],
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // Posisi FAB
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 16.0,
          ), // Beri padding bawah untuk FAB
          child: FloatingActionButton.extended(
            onPressed: _isGeneratingToken ? null : _generateAndDisplayToken,
            tooltip: 'Generate Kode Deposit',
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('SCAN SAYA'),
          ),
        ),
        // body: Center(
        //   // ... (sisa UI HomeScreen dengan tombol Generate QR dan tampilan QR sama) ...
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: <Widget>[
        //         const Text(
        //           'Selamat Datang di Aplikasi RVM!',
        //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        //           textAlign: TextAlign.center,
        //         ),
        //         const SizedBox(height: 40),
        //         ElevatedButton.icon(
        //           icon: const Icon(Icons.qr_code_scanner),
        //           label: const Text('Generate Kode Deposit RVM'),
        //           style: ElevatedButton.styleFrom(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 24,
        //               vertical: 12,
        //             ),
        //             textStyle: const TextStyle(fontSize: 16),
        //           ),
        //           onPressed: _isGeneratingToken ? null : _generateToken,
        //         ),
        //         const SizedBox(height: 20),
        //         if (_isGeneratingToken) const CircularProgressIndicator(),
        //         if (_rvmTokenData != null && !_isGeneratingToken)
        //           Column(
        //             children: [
        //               const Text(
        //                 'Scan QR Code ini di Mesin RVM:',
        //                 style: TextStyle(fontSize: 16),
        //               ),
        //               const SizedBox(height: 10),
        //               QrImageView(
        //                 // Dari package qr_flutter
        //                 data: _rvmTokenData!,
        //                 version: QrVersions.auto,
        //                 size: 200.0,
        //                 gapless: false, // Agar ada sedikit border
        //                 // onError: (ex) {
        //                 //   debugPrint("[QR] ERROR - $ex");
        //                 //   setState((){ _rvmTokenData = null; }); // Handle error QR
        //                 // },
        //               ),
        //               const SizedBox(height: 10),
        //               // Text('Token: $_rvmTokenData'), // Bisa ditampilkan untuk debug
        //               const Text(
        //                 'Kode ini berlaku selama 5 menit.',
        //                 style: TextStyle(fontStyle: FontStyle.italic),
        //               ),
        //             ],
        //           ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );

    // final bool? shouldExit = await showDialog<bool>(
    //   context: context,
    //   builder:
    //       (context) => AlertDialog(
    //         title: const Text('Keluar Aplikasi?'),
    //         content: const Text(
    //           'Apakah Anda yakin ingin keluar dari aplikasi RVM?',
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(false), // Tidak
    //             child: const Text('Tidak'),
    //           ),
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(true), // Ya
    //             child: const Text('Ya'),
    //           ),
    //         ],
    //       ),
    // );

    //   if (shouldExit ?? false) {
    //     debugPrint(
    //       "User memilih keluar dari aplikasi via tombol back di HomeScreen.",
    //     );
    //     SystemNavigator.pop(); // Keluar dari aplikasi
    //   } else {
    //     debugPrint(
    //       "User memilih untuk tidak keluar dari aplikasi dari HomeScreen.",
    //     );
    //   }
    // },
    // child: Scaffold(
    //   appBar: AppBar(
    //     title: const Text('RVM Home'),
    //     automaticallyImplyLeading: false,
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.person),
    //         tooltip: 'Profil',
    //         onPressed: () {
    //           // TODO: Navigasi ke ProfileScreen
    //           debugPrint('Navigasi ke ProfileScreen...');
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             const SnackBar(
    //               content: Text('Halaman Profil belum diimplementasikan.'),
    //             ),
    //           );
    //           // Navigator.of(context).push(
    //           //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
    //           // );
    //         },
    //       ),
    //       IconButton(
    //         icon: const Icon(Icons.logout),
    //         tooltip: 'Logout',
    //         onPressed: _logout,
    //       ),
    //     ],
    //   ),
    //   body: Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           const Text(
    //             'Selamat Datang di Aplikasi RVM!',
    //             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 40),
    //           ElevatedButton.icon(
    //             icon: const Icon(Icons.qr_code_scanner),
    //             label: const Text('Generate Kode Deposit RVM'),
    //             style: ElevatedButton.styleFrom(
    //               padding: const EdgeInsets.symmetric(
    //                 horizontal: 24,
    //                 vertical: 12,
    //               ),
    //               textStyle: const TextStyle(fontSize: 16),
    //             ),
    //             onPressed: _isGeneratingToken ? null : _generateToken,
    //           ),
    //           const SizedBox(height: 20),
    //           if (_isGeneratingToken) const CircularProgressIndicator(),
    //           if (_rvmTokenData != null && !_isGeneratingToken)
    //             Column(
    //               children: [
    //                 const Text(
    //                   'Scan QR Code ini di Mesin RVM:',
    //                   style: TextStyle(fontSize: 16),
    //                 ),
    //                 const SizedBox(height: 10),
    //                 QrImageView(
    //                   // Dari package qr_flutter
    //                   data: _rvmTokenData!,
    //                   version: QrVersions.auto,
    //                   size: 200.0,
    //                   gapless: false, // Agar ada sedikit border
    //                   // onError: (ex) {
    //                   //   debugPrint("[QR] ERROR - $ex");
    //                   //   setState((){ _rvmTokenData = null; }); // Handle error QR
    //                   // },
    //                 ),
    //                 const SizedBox(height: 10),
    //                 // Text('Token: $_rvmTokenData'), // Bisa ditampilkan untuk debug
    //                 const Text(
    //                   'Kode ini berlaku selama 5 menit.',
    //                   style: TextStyle(fontStyle: FontStyle.italic),
    //                 ),
    //               ],
    //             ),
    //         ],
    //       ),
    //     ),
    //   ),
    // ),
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('RVM Home'),
  //       automaticallyImplyLeading: false,
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.person),
  //           tooltip: 'Profil',
  //           onPressed: () {
  //             // TODO: Navigasi ke ProfileScreen
  //             debugPrint('Navigasi ke ProfileScreen...');
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Halaman Profil belum diimplementasikan.'),
  //               ),
  //             );
  //             // Navigator.of(context).push(
  //             //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
  //             // );
  //           },
  //         ),
  //         IconButton(
  //           icon: const Icon(Icons.logout),
  //           tooltip: 'Logout',
  //           onPressed: _logout,
  //         ),
  //       ],
  //     ),
  //     body: Center(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             const Text(
  //               'Selamat Datang di Aplikasi RVM!',
  //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 40),
  //             ElevatedButton.icon(
  //               icon: const Icon(Icons.qr_code_scanner),
  //               label: const Text('Generate Kode Deposit RVM'),
  //               style: ElevatedButton.styleFrom(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 24,
  //                   vertical: 12,
  //                 ),
  //                 textStyle: const TextStyle(fontSize: 16),
  //               ),
  //               onPressed: _isGeneratingToken ? null : _generateToken,
  //             ),
  //             const SizedBox(height: 20),
  //             if (_isGeneratingToken) const CircularProgressIndicator(),
  //             if (_rvmTokenData != null && !_isGeneratingToken)
  //               Column(
  //                 children: [
  //                   const Text(
  //                     'Scan QR Code ini di Mesin RVM:',
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   QrImageView(
  //                     // Dari package qr_flutter
  //                     data: _rvmTokenData!,
  //                     version: QrVersions.auto,
  //                     size: 200.0,
  //                     gapless: false, // Agar ada sedikit border
  //                     // onError: (ex) {
  //                     //   debugPrint("[QR] ERROR - $ex");
  //                     //   setState((){ _rvmTokenData = null; }); // Handle error QR
  //                     // },
  //                   ),
  //                   const SizedBox(height: 10),
  //                   // Text('Token: $_rvmTokenData'), // Bisa ditampilkan untuk debug
  //                   const Text(
  //                     'Kode ini berlaku selama 5 menit.',
  //                     style: TextStyle(fontStyle: FontStyle.italic),
  //                   ),
  //                 ],
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
