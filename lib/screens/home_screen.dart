// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import qr_flutter
import '../services/auth_service.dart';
import 'auth/login_screen.dart'; // Untuk navigasi setelah logout
// import 'profile_screen.dart'; // Nanti kita buat ProfileScreen
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
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RVM Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () {
              // TODO: Navigasi ke ProfileScreen
              debugPrint('Navigasi ke ProfileScreen...');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman Profil belum diimplementasikan.'),
                ),
              );
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
              // );
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
    );
  }
}
