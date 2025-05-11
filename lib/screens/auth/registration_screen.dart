// lib/screens/auth/registration_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart'; // Untuk navigasi setelah registrasi sukses
// LoginScreen tidak perlu diimport jika kita hanya pop, tapi bisa juga untuk pushReplacement
// import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Password dan konfirmasi password tidak cocok.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Pastikan widget masih ada di tree
        if (result['success']) {
          // Registrasi berhasil
          final token = result['data']['access_token'];
          final userName = result['data']['user']['name'];
          debugPrint('Registrasi Berhasil! Token: $token, User: $userName');
          // print('Registrasi Berhasil! Token: $token, User: $userName');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registrasi Berhasil! Selamat datang $userName'),
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Registrasi gagal
          String errorMsg =
              result['message'] ?? 'Terjadi kesalahan saat registrasi.';
          final errors = result['errors'];
          if (errors != null) {
            if (errors['name'] != null) {
              errorMsg += '\nNama: ${errors['name'][0]}';
            }
            if (errors['email'] != null) {
              errorMsg += '\nEmail: ${errors['email'][0]}';
            }
            if (errors['password'] != null) {
              errorMsg += '\nPassword: ${errors['password'][0]}';
            }
          }
          setState(() {
            _errorMessage = errorMsg;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        // Tombol kembali akan muncul otomatis jika layar ini di-push
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Buat Akun RVM',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      debugPrint('Nama tidak boleh kosong');
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      debugPrint('Email tidak boleh kosong');
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      debugPrint('Masukkan email yang valid');
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      debugPrint('Password tidak boleh kosong');
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 8) {
                      debugPrint('Password minimal 8 karakter');
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: _registerUser,
                      child: const Text('Daftar'),
                    ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    // Kembali ke halaman Login
                    // Jika RegistrationScreen di-push dari LoginScreen, kita bisa pop
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      // Jika tidak (misalnya, ini halaman awal), ganti dengan LoginScreen
                      // Ini seharusnya tidak terjadi jika alur normal dari LoginScreen
                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(builder: (context) => const LoginScreen()),
                      // );
                    }
                  },
                  child: const Text('Sudah punya akun? Login di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
