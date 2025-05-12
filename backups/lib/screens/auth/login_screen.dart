// // lib/screens/auth/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../services/auth_service.dart.backup';
// import '../home_screen.dart'; // Untuk navigasi setelah login
// import 'registration_screen.dart'; // Untuk navigasi ke registrasi

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService(); // Instance service auth

//   bool _isLoading = false; // Untuk menampilkan indikator loading
//   String? _errorMessage; // Untuk menampilkan pesan error

//   Future<void> _loginUser() async {
//     if (_formKey.currentState!.validate()) {
//       // Validasi form
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final result = await _authService.login(
//         _emailController.text.trim(),
//         _passwordController.text.trim(),
//       );

//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         if (result['success']) {
//           // Login berhasil
//           // TODO: Simpan token (misalnya, menggunakan shared_preferences atau flutter_secure_storage)
//           // TODO: Navigasi ke HomeScreen
//           final token = result['data']['access_token'];
//           final userName = result['data']['user']['name'];
//           debugPrint('Login Berhasil! Token: $token, User: $userName');
//           // print('Login Berhasil! Token: $token, User: $userName'); // Untuk debug

//           // Contoh navigasi sederhana (ganti dengan navigasi yang benar nanti)
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login Berhasil! Halo $userName')),
//           );
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const HomeScreen()),
//             (Route<dynamic> route) => false,
//           );
//         } else {
//           // Login gagal
//           setState(() {
//             _errorMessage =
//                 result['message'] ?? 'Terjadi kesalahan saat login.';
//             // Jika ada errors spesifik per field dari backend:
//             final errors = result['errors'];
//             if (errors != null && errors['email'] != null) {
//               _errorMessage = errors['email'][0];
//             } else if (errors != null && errors['password'] != null) {
//               _errorMessage = errors['password'][0];
//             }
//             debugPrint(result['message'] ?? 'Terjadi kesalahan saat login.');
//           });
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // WillPopScope untuk mengontrol tombol back fisik di Android
//     return PopScope(
//       canPop: false, // `false` berarti navigasi "back" dicegah
//       onPopInvokedWithResult: (bool didPop, dynamic result) async {
//         // `result` adalah data yang mungkin dikembalikan oleh rute yang di-pop (tidak relevan jika canPop: false)
//         // Callback ini dipanggil SETELAH upaya pop terjadi (atau tidak terjadi).
//         // `didPop` akan false jika canPop adalah false.
//         if (didPop) return;
//         // Seharusnya tidak terjadi jika canPop: false
//         debugPrint(
//           "Upaya 'pop' (tombol back) di LoginScreen dicegah oleh PopScope.",
//         );
//         // Tampilkan dialog konfirmasi
//         final bool? shouldPop = await showDialog<bool>(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text('Keluar Aplikasi?'),
//                 content: const Text(
//                   'Apakah Anda yakin ingin keluar dari aplikasi?',
//                 ),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed:
//                         () => Navigator.of(context).pop(false), // Jangan keluar
//                     child: const Text('Tidak'),
//                   ),
//                   TextButton(
//                     onPressed:
//                         () => Navigator.of(context).pop(true), // Ya, keluar
//                     child: const Text('Ya'),
//                   ),
//                 ],
//               ),
//         );

//         // Jika pengguna memilih "Ya" (shouldPop == true), maka keluar dari aplikasi
//         if (shouldPop ?? false) {
//           // ?? false untuk menangani jika dialog ditutup tanpa pilihan
//           debugPrint(
//             "User memilih keluar dari aplikasi via tombol back di LoginScreen.",
//           );
//           SystemNavigator.pop(); // Keluar dari aplikasi
//         } else {
//           debugPrint("User memilih untuk tidak keluar dari aplikasi.");
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Login RVM User App'),
//           automaticallyImplyLeading:
//               false, // <-- TAMBAHKAN INI untuk menghilangkan tombol back di AppBar
//         ),
//         body: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   Text(
//                     'Selamat Datang!',
//                     style: Theme.of(context).textTheme.headlineMedium,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32.0),
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         debugPrint('Email tidak boleh kosong');
//                         return 'Email tidak boleh kosong';
//                       }
//                       if (!value.contains('@') || !value.contains('.')) {
//                         debugPrint('Masukkan email yang valid');
//                         return 'Masukkan email yang valid';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16.0),
//                   TextFormField(
//                     controller: _passwordController,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.lock),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         debugPrint('Password tidak boleh kosong');
//                         return 'Password tidak boleh kosong';
//                       }
//                       if (value.length < 8) {
//                         debugPrint('Password minimal 8 karakter');
//                         return 'Password minimal 8 karakter';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24.0),
//                   if (_errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: Text(
//                         _errorMessage!,
//                         style: const TextStyle(color: Colors.red, fontSize: 14),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   _isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16.0),
//                           textStyle: const TextStyle(fontSize: 18),
//                         ),
//                         onPressed: _loginUser,
//                         child: const Text('Login'),
//                       ),
//                   const SizedBox(height: 16.0),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => const RegistrationScreen(),
//                         ),
//                       );
//                     },
//                     child: const Text('Belum punya akun? Daftar di sini'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
