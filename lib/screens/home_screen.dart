// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home RVM App'),
        // TODO: Tambahkan tombol logout nanti
      ),
      body: const Center(
        child: Text(
          'Selamat Datang di Aplikasi RVM!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
