// import 'package:flutter/material.dart';
// import 'services/token_service.dart'; // Import TokenService
// import 'services/auth_service.dart.backup'; // Import AuthService
// import 'screens/auth/login_screen.dart'; // Import LoginScreen
// // import 'screens/auth/registration_screen.dart'; // Import RegistrationScreen
// // import 'screens/home_screen.dart'; // Import HomeScreen
// import 'screens/main_shell_screen.dart'; // <-- IMPORT MainShellScreen
// // import 'package:flutter/foundation.dart'; // Untuk debugPrint

// void main() {
//   WidgetsFlutterBinding.ensureInitialized(); // Penting untuk async di main
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MyRVM App',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         // Tambahkan tema untuk input field agar lebih menarik (opsional)
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
//           filled: true,
//           fillColor: Colors.grey[100], // Warna latar field
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green, // Warna tombol utama
//             foregroundColor: Colors.white, // Warna teks tombol utama
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//           ),
//         ),
//       ),

//       // home: const MyHomePage(title: 'Flutter Demo Home Page'),
//       // Hanya gunakan 'home' untuk titik masuk awal Mulai dengan AuthCheckScreen
//       home: const AuthCheckScreen(),
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/main': (context) => const MainShellScreen(),
//         // '/register': (context) => const RegistrationScreen(),
//         // '/home': (context) => const HomeScreen(),
//       },
//       // initialRoute: '/login', // Jika menggunakan routes
//     );
//   }
// }

// class AuthCheckScreen extends StatefulWidget {
//   const AuthCheckScreen({super.key});

//   @override
//   State<AuthCheckScreen> createState() => _AuthCheckScreenState();
// }

// class _AuthCheckScreenState extends State<AuthCheckScreen> {
//   final TokenService _tokenService = TokenService();
//   // Untuk validasi token via profil
//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     String? token = await _tokenService.getToken();
//     if (token != null) {
//       final userProfileData = await _authService.getUserProfile();

//       if (mounted) {
//         if (userProfileData != null) {
//           // ... (navigasi ke main shell) ...
//           debugPrint(
//             'AuthCheckScreen: Token valid, navigasi ke MainShellScreen dan hapus semua rute.',
//           );
//           // Ke /main dan Hapus semua rute sebelumnya
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const MainShellScreen()),
//             (Route<dynamic> route) => false,
//           );
//         } else {
//           // ... (navigasi ke login) ...
//           debugPrint(
//             'AuthCheckScreen: Token tidak valid/kadaluarsa, hapus token lokal.',
//           );
//           await _tokenService.deleteTokenAndUserDetails();
//           if (mounted) {
//             // Ke /login dan Cek mounted lagi setelah await
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (context) => const LoginScreen()),
//               (Route<dynamic> route) => false,
//             );
//           }
//         }
//       }
//     } else {
//       // ... (navigasi ke login sama) ...
//       debugPrint(
//         'AuthCheckScreen: Tidak ada token lokal, navigasi ke LoginScreen.',
//       );
//       if (mounted) {
//         // Ke /login karena tidak ada token di lokal storage
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Tampilan Splash Screen sederhana
//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text("Memeriksa status login..."),
//           ],
//         ),
//       ),
//     );
//   }
// }
