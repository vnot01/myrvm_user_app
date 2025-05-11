import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart'; // Import LoginScreen
import 'screens/auth/registration_screen.dart'; // Import RegistrationScreen
import 'screens/home_screen.dart'; // Import HomeScreen
import 'services/token_service.dart'; // Import TokenService
import 'services/auth_service.dart'; // Import AuthService
// import 'package:flutter/foundation.dart'; // Untuk debugPrint

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Penting untuk async di main
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRVM App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Tambahkan tema untuk input field agar lebih menarik (opsional)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[100], // Warna latar field
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Warna tombol utama
            foregroundColor: Colors.white, // Warna teks tombol utama
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),

      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const AuthCheckScreen(), // Mulai dengan AuthCheckScreen
      // TODO: Setup routes untuk navigasi yang lebih baik nanti
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
      initialRoute: '/login', // Jika menggunakan routes
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
  // Untuk validasi token via profil
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Beri sedikit jeda untuk splash screen atau inisialisasi lain jika perlu
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulasi loading splash screen

    // getToken() bisa mengembalikan null
    String? token = await _tokenService.getToken();
    if (token != null) {
      debugPrint('AuthCheckScreen: Token found: $token');
      // Validasi token dengan mencoba fetch profil
      final userProfile = await _authService.getUserProfile();
      if (mounted) {
        // Cek jika widget masih di tree
        if (userProfile != null) {
          debugPrint('AuthCheckScreen: Token valid, navigating to HomeScreen.');
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Profil gagal diambil, token lokal mungkin tidak valid/kadaluarsa di server
          debugPrint(
            'AuthCheckScreen: Token invalid or expired, navigating to LoginScreen.',
          );
          // Hapus token yang tidak valid
          await _tokenService.deleteTokenAndUserDetails();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } else {
      debugPrint('AuthCheckScreen: No token found, navigating to LoginScreen.');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
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
