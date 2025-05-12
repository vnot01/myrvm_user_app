import 'package:flutter/material.dart';
import 'services/token_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell_screen.dart';
// import 'package:flutter/foundation.dart'; // Kemungkinan tidak perlu jika material.dart sudah cukup

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRVM App',
      theme: ThemeData(
        // Anda bisa ganti seedColor
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[100], // Sesuaikan jika perlu
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.green, // Diambil dari colorScheme.primary jika tidak diset
            // foregroundColor: Colors.white, // Diambil dari colorScheme.onPrimary
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainShellScreen(),
        // '/register': (context) => const RegistrationScreen(), // Bisa ditambahkan jika perlu
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});
  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final TokenService _tokenService = TokenService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    String? token = await _tokenService.getToken();

    if (token != null) {
      debugPrint(
        'AuthCheckScreen: Token ditemukan lokal.',
      ); // Tidak perlu print tokennya di sini
      final userProfileData = await _authService.getUserProfile();

      if (mounted) {
        if (userProfileData != null) {
          debugPrint(
            'AuthCheckScreen: Token valid di server, navigasi ke MainShellScreen.',
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainShellScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          debugPrint(
            'AuthCheckScreen: Token tidak valid/kadaluarsa di server, hapus token lokal.',
          );
          await _tokenService.deleteTokenAndUserDetails();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        }
      }
    } else {
      debugPrint(
        'AuthCheckScreen: Tidak ada token lokal, navigasi ke LoginScreen.',
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Splash Screen sederhana
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Memeriksa status login..."),
          ],
        ),
      ),
    );
  }
}
