// lib/screens/main_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'statistic_screen.dart'; // Pastikan file ini ada
import 'history_screen.dart'; // Pastikan file ini ada

// import '../widgets/qr_modal_sheet.dart'; // Nanti untuk modal
// import '../services/auth_service.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0; // 0: Home, 1: Statistik, (FAB), 2: Riwayat, 3: Profil
  // final AuthService _authService = AuthService(); // Nanti

  // Daftar widget untuk body, tanpa placeholder untuk FAB
  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticScreen(), // Layar untuk tab Statistik
    const HistoryScreen(), // Layar untuk tab Riwayat
    const ProfileScreen(),
  ];

  // Metode untuk menangani tap pada item BottomNavigationBar
  void _onNavItemTapped(int navBarIndex) {
    // navBarIndex akan 0, 1, (skip FAB), 2, 3
    // Kita perlu memetakan ini ke indeks _screens yang benar
    // Home -> 0 (navBar) -> 0 (_screens)
    // Stat -> 1 (navBar) -> 1 (_screens)
    // (FAB di tengah)
    // Hist -> 2 (navBar) -> 2 (_screens)
    // Prof -> 3 (navBar) -> 3 (_screens)

    // Jika kita ingin _currentIndex langsung merepresentasikan indeks di _screens:
    // Maka _buildNavItem harus mengirimkan indeks yang sudah disesuaikan.
    // Atau, kita kelola _selectedScreenIndex terpisah dari _currentIndexBottomNav.
    // Untuk sederhana, _currentIndex akan merujuk ke indeks tap di BottomNav (0,1,2,3)
    // dan kita akan pilih layar dari _screens berdasarkan itu.

    setState(() {
      _currentIndex = navBarIndex;
      debugPrint("BottomNav Tapped: Navbar index $navBarIndex");
    });
  }

  void _handleQrFabPress() {
    debugPrint("FAB QR Ditekan!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tombol QR ditekan! Modal akan muncul di sini.'),
      ),
    );
    // TODO: Implementasi logika untuk menampilkan QrModalSheetWidget
  }

  // Helper untuk mendapatkan widget layar yang aktif
  Widget _getActiveScreen() {
    // Mapping dari _currentIndex (yang merepresentasikan tap di BottomNavBar)
    // ke indeks di _screens list.
    // NavBar: Home(0), Stat(1), FAB(placeholder), Hist(2), Prof(3)
    // Screens: Home(0), Stat(1),            Hist(2), Prof(3)
    if (_currentIndex == 0) return _screens[0]; // Home
    if (_currentIndex == 1) return _screens[1]; // Statistik
    if (_currentIndex == 2) return _screens[2]; // Riwayat
    if (_currentIndex == 3) return _screens[3]; // Profil
    return _screens[0]; // Fallback ke Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar akan diatur oleh masing-masing layar (_getActiveScreen())
      // Ini memberikan fleksibilitas jika setiap tab butuh AppBar berbeda.
      // Jika ingin AppBar global, definisikan di sini dan atur judulnya secara dinamis.
      body: _getActiveScreen(), // Menampilkan layar yang aktif

      floatingActionButton: FloatingActionButton(
        onPressed: _handleQrFabPress,
        tooltip: 'Scan QR Deposit',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4.0, // Sedikit lebih tinggi dari BottomAppBar
        shape: const CircleBorder(),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 26,
            ), // Sesuaikan ukuran ikon
            // SizedBox(height: 1), // Jarak sangat kecil atau tidak ada
            Text(
              'QR',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Membuat lekukan untuk FAB
        notchMargin:
            6.0, // Jarak antara FAB dan lekukan. Sesuaikan agar FAB "pas"
        height: 60.0, // Tinggi BottomAppBar, sesuaikan dengan desain Anda
        // color: Colors.white, // Atau warna tema Anda
        // elevation: 8.0, // Default, bisa disesuaikan
        padding: EdgeInsets.zero, // Hapus padding default jika ada
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildNavItem(
              Icons.home_max_outlined,
              "Home",
              0,
              isSelected: _currentIndex == 0,
            ),
            _buildNavItem(
              Icons.insert_chart_outlined_rounded,
              "Statistik",
              1,
              isSelected: _currentIndex == 1,
            ),
            // Ruang kosong untuk FAB. Ukurannya penting untuk alignment.
            // Lebar FAB standar sekitar 56.0, notchMargin 6.0 kiri & kanan = 12.0. Total ~68-70
            const SizedBox(
              width: 40,
            ), // Sesuaikan lebar ini agar ikon lain terdistribusi baik
            _buildNavItem(
              Icons.history_toggle_off,
              "Riwayat",
              2,
              isSelected: _currentIndex == 2,
            ),
            _buildNavItem(
              Icons.person_pin_circle_outlined,
              "Profil",
              3,
              isSelected: _currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun setiap item di BottomNavigationBar
  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    required bool isSelected,
  }) {
    final color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700];
    return Expanded(
      // Gunakan Expanded agar item mengisi ruang yang tersedia secara merata
      child: InkWell(
        // InkWell untuk efek ripple saat ditekan
        onTap: () => _onNavItemTapped(index),
        customBorder: const CircleBorder(), // Efek ripple bulat
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
          ), // Padding vertikal untuk area tap
          child: Column(
            mainAxisSize:
                MainAxisSize
                    .min, // Agar Column tidak mengambil semua tinggi BottomAppBar
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24), // Ukuran ikon
              const SizedBox(height: 2),
              Text(
                // Teks label di bawah ikon
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10, // Ukuran font label
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
