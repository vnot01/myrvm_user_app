// lib/screens/home_screen.dart
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
  String? _rvmTokenData;
  bool _isGeneratingToken = false;
  // String? _userName;
  // final TokenService _tokenService = TokenService();

  Future<void> _generateToken() async {
    setState(() {
      _isGeneratingToken = true;
      _rvmTokenData = null; // Reset token lama
    });
    final result = await _authService.generateRvmLoginToken();
    if (mounted) {
      setState(() {
        _isGeneratingToken = false;
        if (result['success']) {
          _rvmTokenData = result['data']['rvm_login_token'];
          debugPrint('HomeScreen: RVM Token Generated: $_rvmTokenData');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal generate token RVM'),
            ),
          );
        }
      });
    }
  }

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
          // ... (sisa UI HomeScreen dengan tombol Generate QR dan tampilan QR sama) ...
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Selamat Datang di Aplikasi RVM!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Generate Kode Deposit RVM'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _isGeneratingToken ? null : _generateToken,
                ),
                const SizedBox(height: 20),
                if (_isGeneratingToken) const CircularProgressIndicator(),
                if (_rvmTokenData != null && !_isGeneratingToken)
                  Column(
                    children: [
                      const Text(
                        'Scan QR Code ini di Mesin RVM:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      QrImageView(
                        // Dari package qr_flutter
                        data: _rvmTokenData!,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false, // Agar ada sedikit border
                        // onError: (ex) {
                        //   debugPrint("[QR] ERROR - $ex");
                        //   setState((){ _rvmTokenData = null; }); // Handle error QR
                        // },
                      ),
                      const SizedBox(height: 10),
                      // Text('Token: $_rvmTokenData'), // Bisa ditampilkan untuk debug
                      const Text(
                        'Kode ini berlaku selama 5 menit.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
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
