// // lib/screens/main_shell_screen.dart
// import 'dart:async'; // Untuk Timer di modal jika diputuskan di sini
// import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter/foundation.dart';

// import 'home_screen.dart';
// import 'profile_screen.dart';
// import 'statistic_screen.dart';
// import 'history_screen.dart';
// import '../widgets/qr_modal_sheet.dart'; // <-- IMPORT MODAL QR
// import '../services/auth_service.dart.backup';
// import 'package:screen_brightness/screen_brightness.dart'; // Jika menggunakan

// class MainShellScreen extends StatefulWidget {
//   const MainShellScreen({super.key});

//   @override
//   State<MainShellScreen> createState() => _MainShellScreenState();
// }

// class _MainShellScreenState extends State<MainShellScreen> {
//   int _currentIndex = 0; // 0: Home, 1: Statistik, (FAB), 2: Riwayat, 3: Profil
//   final AuthService _authService = AuthService();
//   bool _isGeneratingQrToken = false; // Untuk FAB loading state

//   // Untuk kontrol kecerahan layar
//   final ScreenBrightness _screenBrightness = ScreenBrightness();
//   double _originalBrightness = 0.5; // Default
//   bool _brightnessPermissionGranted = false; // Simpan status izin
//   bool _brightnessChangedByApp = false; // Tandai jika app yang ubah brightness

//   // Daftar widget untuk body, tanpa placeholder untuk FAB
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const StatisticScreen(), // Layar untuk tab Statistik
//     const HistoryScreen(), // Layar untuk tab Riwayat
//     const ProfileScreen(),
//   ];

//   // Metode untuk menangani tap pada item BottomNavigationBar
//   void _onNavItemTapped(int navBarIndex) {
//     // navBarIndex akan 0, 1, (skip FAB), 2, 3
//     // Kita perlu memetakan ini ke indeks _screens yang benar
//     // Home -> 0 (navBar) -> 0 (_screens)
//     // Stat -> 1 (navBar) -> 1 (_screens)
//     // (FAB di tengah)
//     // Hist -> 2 (navBar) -> 2 (_screens)
//     // Prof -> 3 (navBar) -> 3 (_screens)

//     // Jika kita ingin _currentIndex langsung merepresentasikan indeks di _screens:
//     // Maka _buildNavItem harus mengirimkan indeks yang sudah disesuaikan.
//     // Atau, kita kelola _selectedScreenIndex terpisah dari _currentIndexBottomNav.
//     // Untuk sederhana, _currentIndex akan merujuk ke indeks tap di BottomNav (0,1,2,3)
//     // dan kita akan pilih layar dari _screens berdasarkan itu.

//     setState(() {
//       _currentIndex = navBarIndex;
//       debugPrint("BottomNav Tapped: Navbar index $navBarIndex");
//     });
//   }

//   // Metode untuk meminta izin dan mengatur kecerahan
//   Future<void> _requestAndSetBrightness() async {
//     // Placeholder, implementasi nyata dengan package screen_brightness
//     if (!_brightnessPermissionGranted) {
//       // Tampilkan dialog minta izin
//       // Jika diizinkan, _brightnessPermissionGranted = true;
//     }
//     if (_brightnessPermissionGranted) {
//       try {
//         _originalBrightness = await _screenBrightness.current;
//         await _screenBrightness.setScreenBrightness(1.0);
//         _brightnessChangedByApp = true;
//         debugPrint("MainShell: Kecerahan dimaksimalkan.");
//       } catch (e) {
//         debugPrint("MainShell: Gagal set kecerahan: $e");
//       }
//     }
//     debugPrint("MainShell: Placeholder _requestAndSetBrightness dipanggil.");
//     // Untuk sekarang, kita anggap berhasil dan brightness di-set
//     _brightnessChangedByApp = true; // Asumsikan kita ubah
//   }

//   Future<void> _resetBrightnessIfNeeded() async {
//     // Placeholder
//     if (_brightnessChangedByApp) {
//       try {
//         await _screenBrightness.setScreenBrightness(_originalBrightness);
//         _brightnessChangedByApp = false;
//         debugPrint("MainShell: Kecerahan dikembalikan.");
//       } catch (e) {
//         debugPrint("MainShell: Gagal kembalikan kecerahan: $e");
//       }
//     }
//     debugPrint("MainShell: Placeholder _resetBrightnessIfNeeded dipanggil.");
//   }

//   Future<void> _handleQrFabPress() async {
//     if (_isGeneratingQrToken) return;
//     setState(() {
//       _isGeneratingQrToken = true;
//     });

//     await _requestAndSetBrightness(); // Minta izin dan naikkan brightness

//     final result = await _authService.generateRvmLoginToken();
//     // Variabel untuk menyimpan token yang akan ditampilkan
//     String? tokenToDisplay;

//     if (mounted) {
//       if (result['success']) {
//         tokenToDisplay = result['data']?['rvm_login_token'] as String?;
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? 'Gagal generate token awal'),
//           ),
//         );
//         setState(() {
//           _isGeneratingQrToken = false;
//         });
//         await _resetBrightnessIfNeeded(); // Kembalikan brightness jika gagal
//         return; // Keluar jika gagal generate token awal
//       }
//     } else {
//       return;
//     } // Widget sudah tidak ada
//     if (tokenToDisplay == null) {
//       setState(() {
//         _isGeneratingQrToken = false;
//       });
//       // await _resetBrightnessIfNeeded();
//       return;
//     }

//     // Loop untuk menampilkan modal dan handle regenerate
//     bool keepShowingModal = true;
//     while (keepShowingModal && mounted) {
//       if (_isGeneratingQrToken && tokenToDisplay == null) {
//         // Jika sedang generate ulang
//         final regenResult = await _authService.generateRvmLoginToken();
//         if (mounted && regenResult['success']) {
//           tokenToDisplay = regenResult['data']?['rvm_login_token'] as String?;
//         } else if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 regenResult['message'] ?? 'Gagal generate ulang token',
//               ),
//             ),
//           );
//           tokenToDisplay = null; // Gagal generate ulang
//           keepShowingModal = false; // Hentikan loop modal
//         }
//         if (mounted)
//           setState(() {
//             _isGeneratingQrToken = false;
//           });
//         if (tokenToDisplay == null) break; // Keluar jika gagal generate ulang
//       }

//       // Tampilkan Modal Bottom Sheet
//       final modalResult = await showModalBottomSheet<String?>(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         isDismissible:
//             true, // Biarkan bisa di-dismiss dengan swipe atau tap di luar
//         enableDrag: true, // Aktifkan swipe down untuk menutup
//         builder: (BuildContext bc) {
//           return QrModalSheetWidget(
//             // Sekarang pasti tidak null
//             // onGenerateNewTokenNeeded dihandle oleh tombol di modal yang pop dengan 'regenerate_token'
//             initialRvmToken: tokenToDisplay!,
//             onRequestBrightnessPermission: () async {
//               /* ... panggil _requestAndSetBrightness ... */
//             },
//             onSetBrightness: (maximize) async {
//               /* ... panggil _setBrightness ... */
//               if (maximize) {
//                 await _screenBrightness.setScreenBrightness(1.0);
//                 debugPrint("MODAL: Brightness diminta MAX");
//               } else {
//                 await _screenBrightness.setScreenBrightness(
//                   _originalBrightness,
//                 );
//                 debugPrint("MODAL: Brightness diminta RESET");
//               }
//             },
//           );
//         },
//       );

//       await _resetBrightnessIfNeeded(); // Kembalikan brightness setelah modal ditutup

//       if (modalResult == 'regenerate_token') {
//         debugPrint("MainShell: Diminta untuk regenerate token dari modal.");
//         // Tampilkan loading untuk generate berikutnya
//         setState(() {
//           _isGeneratingQrToken = true;
//         });
//         // Kosongkan token agar di-generate ulang di awal loop while
//         tokenToDisplay = null;
//         // Loop akan berlanjut dan memanggil generate token lagi
//       } else if (modalResult == 'scan_success') {
//         debugPrint(
//           "MainShell: Scan sukses terdeteksi dari modal, tutup modal loop.",
//         );
//         // TODO: Refresh data user
//         keepShowingModal = false;
//       } else {
//         // Modal ditutup dengan cara lain (swipe, tombol X, back button)
//         debugPrint(
//           "MainShell: Modal QR ditutup (hasil: $modalResult). Hentikan loop modal.",
//         );
//         keepShowingModal = false;
//       }
//     } // Akhir while keepShowingModal

//     // Pastikan loading direset jika loop selesai
//     if (mounted && _isGeneratingQrToken) {
//       setState(() {
//         _isGeneratingQrToken = false;
//       });
//     }
//     // Pastikan brightness dikembalikan
//     await _resetBrightnessIfNeeded();
//   }

//   // if (mounted) {
//   //   setState(() {
//   //     _isGeneratingQrToken = false;
//   //   });
//   //   if (result['success']) {
//   //     final tokenData = result['data']?['rvm_login_token'] as String?;
//   //     if (tokenData != null) {
//   //       // Tampilkan Modal Bottom Sheet
//   //       final modalResult = await showModalBottomSheet<String?>(
//   //         // Bisa mengembalikan nilai
//   //         context: context,
//   //         isScrollControlled: true, // Penting agar modal bisa lebih tinggi
//   //         backgroundColor:
//   //             Colors
//   //                 .transparent, // Agar modal bisa punya border radius sendiri
//   //         builder: (BuildContext bc) {
//   //           return QrModalSheetWidget(
//   //             initialRvmToken: tokenData,
//   //             onGenerateNewTokenNeeded: () {
//   //               // Callback jika user klik "Generate Ulang" di modal
//   //               Navigator.of(bc).pop(); // Tutup modal saat ini
//   //               _handleQrFabPress(); // Panggil lagi untuk generate token baru
//   //             },
//   //             onRequestBrightnessPermission:
//   //                 _requestAndSetBrightness, // Teruskan fungsi
//   //             onSetBrightness: (maximize) async {
//   //               // Fungsi untuk set brightness
//   //               if (maximize) {
//   //                 // await _screenBrightness.setScreenBrightness(1.0);
//   //                 debugPrint("MODAL: Brightness diminta MAX");
//   //               } else {
//   //                 // await _screenBrightness.setScreenBrightness(_originalBrightness);
//   //                 debugPrint("MODAL: Brightness diminta RESET");
//   //               }
//   //             },
//   //           );
//   //         },
//   //       );
//   //       // Dipanggil setelah modal ditutup
//   //       await _resetBrightnessIfNeeded();
//   //       debugPrint("MainShell: Modal QR ditutup, hasil: $modalResult");
//   //       if (modalResult == 'regenerate') {
//   //         // Jika modal ditutup dengan permintaan regenerate
//   //         // _handleQrFabPress(); // Bisa langsung panggil lagi atau tunggu user tekan FAB
//   //       } else if (modalResult == 'scan_success') {
//   //         // TODO: Refresh data user (poin, riwayat) di HomeScreen atau global state
//   //         debugPrint(
//   //           "MainShell: Scan sukses terdeteksi, refresh data user diperlukan.",
//   //         );
//   //       }
//   //     } else {
//   //       /* ... SnackBar error token data null ... */

//   //       debugPrint("HandleQRFabPress: SnackBar error token data null.");
//   //     }
//   //   } else {
//   //     /* ... SnackBar error API gagal ... */

//   //     debugPrint("HandleQRFabPress: SnackBar error API gagal.");
//   //   }
//   // }
//   // }

//   // Helper untuk mendapatkan widget layar yang aktif
//   Widget _getActiveScreen() {
//     // Mapping dari _currentIndex (yang merepresentasikan tap di BottomNavBar)
//     // ke indeks di _screens list.
//     // NavBar: Home(0), Stat(1), FAB(placeholder), Hist(2), Prof(3)
//     // Screens: Home(0), Stat(1),            Hist(2), Prof(3)
//     if (_currentIndex == 0) return _screens[0]; // Home
//     if (_currentIndex == 1) return _screens[1]; // Statistik
//     if (_currentIndex == 2) return _screens[2]; // Riwayat
//     if (_currentIndex == 3) return _screens[3]; // Profil
//     return _screens[0]; // Fallback ke Home
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // AppBar akan diatur oleh masing-masing layar (_getActiveScreen())
//       // Ini memberikan fleksibilitas jika setiap tab butuh AppBar berbeda.
//       // Jika ingin AppBar global, definisikan di sini dan atur judulnya secara dinamis.
//       body: _getActiveScreen(), // Menampilkan layar yang aktif
//       floatingActionButton: FloatingActionButton(
//         onPressed: _handleQrFabPress,
//         tooltip: 'Scan QR Deposit',
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//         elevation: 4.0, // Sedikit lebih tinggi dari BottomAppBar
//         shape: const CircleBorder(),
//         child: const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Icon(
//               Icons.qr_code_scanner_rounded,
//               size: 26,
//             ), // Sesuaikan ukuran ikon
//             // SizedBox(height: 1), // Jarak sangat kecil atau tidak ada
//             Text(
//               'QR',
//               style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(), // Membuat lekukan untuk FAB
//         notchMargin:
//             6.0, // Jarak antara FAB dan lekukan. Sesuaikan agar FAB "pas"
//         height: 60.0, // Tinggi BottomAppBar, sesuaikan dengan desain Anda
//         // color: Colors.white, // Atau warna tema Anda
//         // elevation: 8.0, // Default, bisa disesuaikan
//         padding: EdgeInsets.zero, // Hapus padding default jika ada
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             _buildNavItem(
//               Icons.home_max_outlined,
//               "Home",
//               0,
//               isSelected: _currentIndex == 0,
//             ),
//             _buildNavItem(
//               Icons.insert_chart_outlined_rounded,
//               "Statistik",
//               1,
//               isSelected: _currentIndex == 1,
//             ),
//             // Ruang kosong untuk FAB. Ukurannya penting untuk alignment.
//             // Lebar FAB standar sekitar 56.0, notchMargin 6.0 kiri & kanan = 12.0. Total ~68-70
//             const SizedBox(
//               width: 40,
//             ), // Sesuaikan lebar ini agar ikon lain terdistribusi baik
//             _buildNavItem(
//               Icons.history_toggle_off,
//               "Riwayat",
//               2,
//               isSelected: _currentIndex == 2,
//             ),
//             _buildNavItem(
//               Icons.person_pin_circle_outlined,
//               "Profil",
//               3,
//               isSelected: _currentIndex == 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget untuk membangun setiap item di BottomNavigationBar
//   Widget _buildNavItem(
//     IconData icon,
//     String label,
//     int index, {
//     required bool isSelected,
//   }) {
//     final color =
//         isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700];
//     return Expanded(
//       // Gunakan Expanded agar item mengisi ruang yang tersedia secara merata
//       child: InkWell(
//         // InkWell untuk efek ripple saat ditekan
//         onTap: () => _onNavItemTapped(index),
//         customBorder: const CircleBorder(), // Efek ripple bulat
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 4.0,
//           ), // Padding vertikal untuk area tap
//           child: Column(
//             mainAxisSize:
//                 MainAxisSize
//                     .min, // Agar Column tidak mengambil semua tinggi BottomAppBar
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 24), // Ukuran ikon
//               const SizedBox(height: 2),
//               Text(
//                 // Teks label di bawah ikon
//                 label,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 10, // Ukuran font label
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
