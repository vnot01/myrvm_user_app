// lib/screens/main_shell_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
// Untuk SystemNavigator
// Untuk debugPrint
import 'home_screen.dart';
import 'profile_screen.dart';
import 'statistic_screen.dart'; // Pastikan file ini ada
import 'history_screen.dart'; // Pastikan file ini ada
import '../widgets/qr_modal_sheet.dart';
import '../services/auth_service.dart';
import 'package:screen_brightness/screen_brightness.dart'; // Untuk kontrol kecerahan

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  // final GlobalKey<RefreshIndicatorState> _profileRefreshIndicatorKey =
  //     GlobalKey<RefreshIndicatorState>();
  final GlobalKey<State<ProfileScreen>> _profileScreenKey =
      GlobalKey<State<ProfileScreen>>();
  // Jika HomeScreen juga perlu refresh
  // final GlobalKey<_HomeScreenState> _homeScreenKey = GlobalKey<_HomeScreenState>();
  // 0: Home, 1: Statistik, (FAB), 2: Riwayat, 3: Profil
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  // Untuk FAB loading state
  bool _isGeneratingQrToken = false;

  // Untuk kontrol kecerahan layar
  final ScreenBrightness _screenBrightness = ScreenBrightness();
  // default
  double _originalBrightness = 0.5;
  // Lacak apakah sudah ditanya di sesi ini
  bool _brightnessPermissionAskedThisSession = false;
  // Simpan status izin (bisa dari SharedPreferences nanti)
  bool _brightnessPermissionPreviouslyGranted = false;
  bool _brightnessChangedByApp = false;
  // Jadikan late
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inisialisasi _screens DI DALAM initState
    _screens = [
      const HomeScreen(), // Atau HomeScreen(key: _homeScreenKey),
      const StatisticScreen(),
      const HistoryScreen(),
      ProfileScreen(key: _profileScreenKey), // Teruskan key di sini
    ];
  }
  // final List<Widget> _screens = [
  //   const HomeScreen(),
  //   const StatisticScreen(), // Layar untuk tab Statistik
  //   const HistoryScreen(), // Layar untuk tab Riwayat
  //   const ProfileScreen(),
  // ];

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

  // Metode untuk meminta izin kecerahan jika belum pernah atau ditolak
  Future<bool> _requestBrightnessPermissionIfNeeded() async {
    if (_brightnessPermissionPreviouslyGranted) {
      // Jika sudah pernah diizinkan (misal dari sesi lalu)
      debugPrint(
        "MainShell: _brightnessPermissionPreviouslyGranted: Izin kecerahan sudah pernah diizinkan (misal dari sesi lalu).",
      );
      return true;
    }
    if (_brightnessPermissionAskedThisSession &&
        !_brightnessPermissionPreviouslyGranted) {
      // Jika sudah ditanya di sesi ini dan ditolak, jangan tanya lagi di sesi ini.
      // Atau, Anda bisa memutuskan untuk selalu bertanya. Untuk sekarang, kita anggap tidak tanya lagi di sesi ini.
      debugPrint(
        "MainShell: _brightnessPermissionAskedThisSession: Izin kecerahan sudah ditolak di sesi ini.",
      );
      return false;
    }
    // Tandai sudah ditanya di sesi ini
    _brightnessPermissionAskedThisSession = true;
    if (!mounted) return false;

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Optimalkan Scan QR'),
          content: const Text(
            'Untuk pembacaan QR yang lebih baik oleh mesin, izinkan aplikasi meningkatkan kecerahan layar Anda sementara?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Lain Kali'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Izinkan'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      debugPrint("MainShell: User mengizinkan perubahan kecerahan.");
      _brightnessPermissionPreviouslyGranted = true; // Simpan status izin
      // TODO: Simpan pilihan ini ke SharedPreferences jika ingin diingat antar sesi aplikasi
      return true;
    } else {
      debugPrint("MainShell: User tidak mengizinkan perubahan kecerahan.");
      _brightnessPermissionPreviouslyGranted = false;
      return false;
    }
  }

  // Metode untuk mengatur kecerahan (dipanggil dari modal atau dari sini)
  Future<void> _setScreenBrightness(bool maximize) async {
    if (!_brightnessPermissionPreviouslyGranted && maximize) {
      // Jika belum ada izin dan mau maksimalkan, jangan lakukan apa-apa
      // Atau bisa juga panggil _requestBrightnessPermissionIfNeeded() lagi
      debugPrint(
        "MainShell: Tidak ada izin untuk mengubah kecerahan ke maksimal.",
      );
      return;
    }

    try {
      if (maximize) {
        if (!_brightnessChangedByApp) {
          // Hanya simpan original jika belum diubah oleh app
          _originalBrightness = await _screenBrightness.current;
        }
        await _screenBrightness.setScreenBrightness(1.0); // Maksimum
        _brightnessChangedByApp = true;
        debugPrint("MainShell: Kecerahan layar dimaksimalkan.");
      } else {
        // Reset brightness
        if (_brightnessChangedByApp) {
          // Hanya reset jika app yang mengubahnya
          await _screenBrightness.setScreenBrightness(_originalBrightness);
          _brightnessChangedByApp = false;
          debugPrint(
            "MainShell: Kecerahan layar dikembalikan ke: $_originalBrightness",
          );
        }
      }
    } catch (e) {
      debugPrint("MainShell: Gagal set/reset kecerahan: $e");
    }
  }

  // Future<void> _refreshUserData() async {
  //   debugPrint("MainShell: Memulai refresh data pengguna...");
  Future<void> _refreshUserData() async {
    debugPrint("MainShell: Memulai refresh data pengguna...");
    // Coba panggil refreshProfile jika state ada dan tipenya sesuai

    final profileState = _profileScreenKey.currentState;
    // final profileScreenState = _profileScreenKey.currentState;
    if (profileState != null) {
      // Kita tahu bahwa `profileState` adalah instance dari `_ProfileScreenState`
      // meskipun tipenya `State<ProfileScreen>`.
      // Dart memungkinkan pemanggilan metode jika ada di runtime.
      try {
        // Ini adalah cara untuk memanggil metode pada objek yang tipenya
        // tidak sepenuhnya diketahui saat kompilasi, tapi kita tahu metodenya ada.
        // 'refreshProfile' adalah nama metode di _ProfileScreenState.
        (profileState as dynamic).refreshProfile();
        debugPrint(
          "MainShell: Metode refreshProfile() di ProfileScreen dipanggil.",
        );
      } catch (e) {
        debugPrint(
          "MainShell: Gagal memanggil refreshProfile: $e. Mungkin metode tidak ditemukan atau state tidak cocok.",
        );
        // Fallback: Panggil setState di MainShell untuk memicu rebuild jika ProfileScreen aktif
        if (mounted) setState(() {});
      }
    } else {
      debugPrint(
        "MainShell: Tidak bisa mendapatkan currentState dari ProfileScreen untuk refresh.",
      );
      // Fallback: Panggil setState di MainShell
      if (mounted) setState(() {});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pengguna sedang diperbarui...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  // // Cara memanggil metode refresh di ProfileScreen:
  // // Kita perlu ProfileScreen mengekspos metode ini.
  // // Untuk sekarang, kita asumsikan ProfileScreen akan otomatis refresh
  // // jika datanya berubah di state global, atau kita akan implementasi ini nanti.
  // // Atau, jika ProfileScreen menggunakan FutureBuilder yang di-trigger oleh perubahan key
  // // atau parameter, kita bisa memicunya.

  // // Untuk sekarang, kita hanya log dan tampilkan SnackBar
  // // Panggil metode refresh pada ProfileScreen jika key dan state-nya ada
  // // Ini memerlukan _ProfileScreenState untuk mengekspos metode refreshProfile()
  // // dan GlobalKey bertipe GlobalKey<_ProfileScreenState> (yang private).
  // // Solusi lebih baik: ProfileScreen menggunakan Provider atau BLoC,
  // // dan kita trigger update dari sini.

  // // Untuk sekarang, kita hanya akan memanggil setState di MainShell
  // // dan berharap ProfileScreen (jika aktif) akan rebuild dan FutureBuilder-nya
  // // mengambil data terbaru. Ini tidak ideal jika ProfileScreen tidak aktif.
  // final refreshedProfile =
  //     await _authService.getUserProfile(); // Ambil profil lagi
  // if (mounted) {
  //   if (refreshedProfile != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Data pengguna telah diperbarui!'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     // Jika Anda punya cara untuk update ProfileScreen secara eksplisit, panggil di sini.
  //     // Contoh: _profileScreenKey.currentState?.refresh(); // Jika ProfileScreen punya metode refresh()
  //     // Untuk sekarang, jika ProfileScreen adalah tab aktif, ia akan rebuild saat setState MainShell.
  //     // Jika tidak, saat dibuka lagi, initState-nya akan fetch data baru.
  //     setState(() {
  //       // Mungkin update data user yang disimpan di MainShell jika ada
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Gagal memperbarui data pengguna.'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }
  // debugPrint("MainShell: Perintah refresh data pengguna telah diproses.");
  // }

  Future<void> _handleQrFabPress() async {
    if (_isGeneratingQrToken) {
      debugPrint("MainShell: Sedang generate token, mohon tunggu...");
      return;
    }
    setState(() {
      _isGeneratingQrToken = true;
    });

    bool canChangeBrightness = await _requestBrightnessPermissionIfNeeded();
    // Naikkan brightness jika diizinkan
    if (canChangeBrightness) {
      await _setScreenBrightness(true);
    }

    final result = await _authService.generateRvmLoginToken();
    String? tokenToDisplay;

    if (mounted) {
      if (result['success']) {
        tokenToDisplay = result['data']?['rvm_login_token'] as String?;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal generate token awal'),
          ),
        );
        setState(() {
          _isGeneratingQrToken = false;
        });
        // Kembalikan brightness
        if (canChangeBrightness) await _setScreenBrightness(false);
        return;
      }
    } else {
      return;
    }

    if (tokenToDisplay == null) {
      setState(() {
        _isGeneratingQrToken = false;
      });
      if (canChangeBrightness) await _setScreenBrightness(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendapatkan data token dari server.'),
        ),
      );
      return;
    }

    // Jika sampai sini, token berhasil di-generate
    setState(() {
      _isGeneratingQrToken = false;
    }); // Selesai loading untuk FAB

    final modalResult = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext bc) {
        return QrModalSheetWidget(
          initialRvmToken: tokenToDisplay!,
          // --- PERBAIKAN: Tambahkan onGenerateNewTokenNeeded ---
          // Tutup modal ini dan kirim sinyal
          onGenerateNewTokenNeeded: () {
            Navigator.of(bc).pop('regenerate_token');
          },
          // --- Akhir Perbaikan ---
          // Teruskan fungsi
          onRequestBrightnessPermission: _requestBrightnessPermissionIfNeeded,
          // Teruskan fungsi
          onSetBrightness: _setScreenBrightness,
        );
      },
    );

    // Setelah modal ditutup
    await _setScreenBrightness(false); // Selalu coba kembalikan brightness
    debugPrint("MainShell: Modal QR ditutup, hasil: $modalResult");

    if (modalResult == 'regenerate_token') {
      debugPrint(
        "MainShell: Diminta untuk regenerate token dari modal. Memanggil FAB press lagi.",
      );
      _handleQrFabPress(); // Panggil lagi untuk generate token baru
    } else if (modalResult == 'scan_success') {
      debugPrint(
        "MainShell: Scan sukses terdeteksi dari modal, refresh data user diperlukan.",
      );
      _refreshUserData(); // Buat fungsi baru untuk ini
      // TODO: Panggil metode untuk me-refresh data user (misalnya, poin di HomeScreen atau ProfileScreen)
      // Contoh: Provider.of<UserNotifier>(context, listen: false).fetchUserProfile();
    }
  }

  Widget _getActiveScreen() {
    // Mapping dari _currentIndex (yang merepresentasikan tap di BottomNavBar)
    // ke indeks di _screens list.
    // NavBar: Home(0), Stat(1), FAB(placeholder), Hist(2), Prof(3)
    // Screens: Home(0), Stat(1),            Hist(2), Prof(3)
    if (_currentIndex == 0) return _screens[0]; // Home
    if (_currentIndex == 1) return _screens[1]; // Statistik
    if (_currentIndex == 2) return _screens[2]; // Riwayat
    if (_currentIndex == 3) return _screens[3]; // Profil
    // return _screens[0]; // Fallback ke Home
    return _screens[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    // ... (Scaffold, FAB, BottomAppBar sama seperti sebelumnya) ...
    // Pastikan FAB memanggil _handleQrFabPress
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

    // return IconButton(
    //   icon: Icon(icon),
    //   onPressed: () => _onNavItemTapped(index),
    // );
  }
}
