// // lib/widgets/qr_modal_sheet.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import '../services/auth_service.dart.backup'; // Untuk generate ulang dan polling
// // import 'package:flutter/foundation.dart';
// // import 'package:screen_brightness/screen_brightness.dart'; // Jika menggunakan

// class QrModalSheetWidget extends StatefulWidget {
//   final String initialRvmToken;
//   final VoidCallback
//   onGenerateNewTokenNeeded; // Callback jika user ingin generate baru dari modal
//   final Future<void> Function()
//   onRequestBrightnessPermission; // Callback untuk minta izin brightness
//   final Future<void> Function(bool maximize)
//   onSetBrightness; // Callback untuk set brightness

//   const QrModalSheetWidget({
//     super.key,
//     required this.initialRvmToken,
//     required this.onGenerateNewTokenNeeded,
//     required this.onRequestBrightnessPermission,
//     required this.onSetBrightness,
//   });

//   @override
//   State<QrModalSheetWidget> createState() => _QrModalSheetWidgetState();
// }

// class _QrModalSheetWidgetState extends State<QrModalSheetWidget> {
//   final AuthService _authService = AuthService();
//   String? _activeRvmToken;
//   Timer? _qrTokenTimer;
//   Timer? _pollingTimer;
//   Duration _timeLeft = const Duration(minutes: 5);
//   bool _isGeneratingNewToken = false;
//   bool _scanSuccessful = false;

//   @override
//   void initState() {
//     super.initState();
//     _activeRvmToken = widget.initialRvmToken;
//     _startQrTimerAndPolling();
//     // Panggil set brightness setelah widget dibangun agar context valid
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       widget.onSetBrightness(true); // Maksimalkan brightness
//     });
//   }

//   void _startQrTimerAndPolling() {
//     _qrTokenTimer?.cancel();
//     _pollingTimer?.cancel();
//     setState(() {
//       _timeLeft = const Duration(minutes: 5);
//       _scanSuccessful = false; // Reset status scan sukses
//     });

//     _qrTokenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       if (_timeLeft.inSeconds == 0) {
//         timer.cancel();
//         _pollingTimer?.cancel(); // Hentikan polling jika timer habis
//         setState(() {
//           _activeRvmToken = null; // Token expired, tampilkan placeholder
//           debugPrint("QrModalSheet: Timer QR Code habis.");
//         });
//         widget.onSetBrightness(false); // Kembalikan brightness
//       } else {
//         setState(() {
//           _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
//         });
//       }
//     });
//     _startPollingScanStatus(); // Mulai polling
//   }

//   void _startPollingScanStatus() {
//     if (_activeRvmToken == null) return;
//     _pollingTimer?.cancel(); // Hentikan polling lama jika ada

//     _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) async {
//       // Polling setiap 7 detik
//       if (!mounted || _activeRvmToken == null || _timeLeft.inSeconds == 0) {
//         timer.cancel();
//         return;
//       }
//       debugPrint(
//         "QrModalSheet: Polling status scan untuk token: $_activeRvmToken",
//       );
//       final result = await _authService.checkRvmScanStatus(_activeRvmToken!);
//       if (mounted &&
//           result['success'] == true &&
//           result['status'] == 'scanned_and_validated') {
//         timer.cancel();
//         _qrTokenTimer?.cancel();
//         widget.onSetBrightness(false); // Kembalikan brightness
//         setState(() {
//           _scanSuccessful = true;
//         });

//         // Tampilkan dialog sukses
//         await showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (BuildContext dialogCtx) => AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 title: const Center(
//                   child: Icon(
//                     Icons.check_circle_rounded,
//                     color: Colors.green,
//                     size: 60,
//                   ),
//                 ),
//                 content: const Text(
//                   'Scan Berhasil!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 actionsAlignment: MainAxisAlignment.center,
//                 actions: <Widget>[
//                   TextButton(
//                     child: const Text('OK', style: TextStyle(fontSize: 16)),
//                     onPressed: () {
//                       Navigator.of(dialogCtx).pop(); // Tutup dialog sukses
//                       if (mounted && Navigator.canPop(context)) {
//                         Navigator.of(context).pop(
//                           true,
//                         ); // Tutup modal QR, kembalikan true (menandakan sukses)
//                       }
//                     },
//                   ),
//                 ],
//               ),
//         );
//       } else if (result['status'] == 'token_expired_or_invalid') {
//         timer.cancel(); // Hentikan polling jika token sudah tidak valid
//         _qrTokenTimer?.cancel();
//         if (mounted) {
//           setState(() {
//             _activeRvmToken = null;
//           });
//         }
//         widget.onSetBrightness(false);
//       }
//     });
//   }

//   Future<void> _handleGenerateNewToken() async {
//     if (_isGeneratingNewToken) return;
//     setState(() {
//       _isGeneratingNewToken = true;
//     });

//     // Minta izin brightness lagi jika perlu (logika dari HomeScreen bisa dipanggil via callback)
//     await widget.onRequestBrightnessPermission();
//     // Panggil callback yang akan memicu generate token di HomeScreen/MainShell
//     // dan HomeScreen/MainShell akan menutup modal ini lalu membuka yang baru
//     // atau modal ini bisa menerima token baru dan mereset dirinya.
//     // Untuk sekarang, kita panggil callback yang menandakan butuh token baru.
//     widget.onGenerateNewTokenNeeded();

//     // // Jika modal ini akan generate sendiri:
//     // // final result = await _authService.generateRvmLoginToken();
//     // // if (mounted) {
//     // //   if (result['success']) {
//     // //     final newToken = result['data']?['rvm_login_token'] as String?;
//     // //     if (newToken != null) {
//     // //       setState(() {
//     // //         _activeRvmToken = newToken;
//     // //         _isGeneratingNewToken = false;
//     // //       });
//     // //       _startOrResetQrTimerAndPolling(); // Mulai timer dan polling untuk token baru
//     // //       await widget.onSetBrightness(true); // Maksimalkan brightness lagi
//     // //     } else { /* handle error */ setState(() { _isGeneratingNewToken = false; });}
//     // //   } else { /* handle error */ setState(() { _isGeneratingNewToken = false; });}
//     // // }
//     // // Untuk saat ini, biarkan HomeScreen yang handle generate ulang setelah modal ini ditutup.
//     // // Jadi, tombol "Generate Ulang" akan menutup modal ini dan memicu HomeScreen.
//     // if (mounted && Navigator.canPop(context)) {
//     //   Navigator.of(context).pop('regenerate'); // Kembalikan 'regenerate'
//     // }

//     // Di _QrModalSheetWidgetState, dalam metode _handleGenerateNewToken()
//     // (atau metode yang dipanggil oleh tombol "Generate Ulang Kode")
//     Future<void> _triggerRegenerateFromParent() async {
//       if (!mounted) return;
//       // Beri tahu parent (MainShellScreen) bahwa kita ingin regenerate
//       Navigator.of(context).pop('regenerate_token');
//     }

//     // Di build() method, untuk tombol "Generate Ulang Kode":
//     // ...
//     ElevatedButton.icon(
//       icon: const Icon(Icons.qr_code_scanner_rounded),
//       label: const Text("Generate Ulang Kode"),
//       onPressed:
//           _isGeneratingNewToken
//               ? null
//               : _triggerRegenerateFromParent, // Panggil ini
//     );
//   }

//   @override
//   void dispose() {
//     _qrTokenTimer?.cancel();
//     _pollingTimer?.cancel();
//     // Penting: Kembalikan kecerahan layar saat modal di-dispose
//     // Ini akan dipanggil jika modal ditutup dengan swipe atau tombol X
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         // Pastikan masih mounted jika ada operasi async
//         widget.onSetBrightness(false);
//       }
//     });
//     debugPrint(
//       "QrModalSheet disposed, timers cancelled, brightness reset attempted.",
//     );
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20.0),
//       decoration: const BoxDecoration(
//         color: Colors.white, // Atau warna tema Anda
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20.0),
//           topRight: Radius.circular(20.0),
//         ),
//       ),
//       child: Wrap(
//         // Wrap agar konten tidak meluap di layar kecil
//         alignment: WrapAlignment.center,
//         runSpacing: 15.0,
//         children: <Widget>[
//           // Baris Judul dan Tombol Tutup
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Pindai Kode QR Ini",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Menutup modal bottom sheet
//                 },
//               ),
//             ],
//           ),

//           // Area QR Code atau Placeholder
//           if (_activeRvmToken != null &&
//               _timeLeft.inSeconds > 0 &&
//               !_isGeneratingNewToken)
//             QrImageView(
//               data: _activeRvmToken!,
//               version: QrVersions.auto,
//               size:
//                   MediaQuery.of(context).size.width *
//                   0.6, // Ukuran QR responsif
//               gapless: false,
//             )
//           else if (!_isGeneratingNewToken) // Placeholder jika expired atau belum ada
//             Column(
//               children: [
//                 Icon(
//                   Icons.qr_code_scanner_outlined,
//                   size: 100,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Kode QR tidak aktif atau sudah kedaluwarsa.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),

//           if (_isGeneratingNewToken) // Indikator loading saat generate ulang
//             const Padding(
//               padding: EdgeInsets.symmetric(
//                 vertical: 80.0,
//               ), // Beri ruang untuk loading
//               child: CircularProgressIndicator(),
//             ),

//           // Teks Instruksi
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 10.0),
//             child: Text(
//               "Arahkan kode ini ke kamera pada mesin RVM. Sistem akan membaca kode Anda secara otomatis.",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.black54),
//             ),
//           ),

//           // Tombol Dinamis (Timer atau Generate Ulang)
//           SizedBox(
//             width: double.infinity, // Tombol selebar modal
//             child:
//                 (_activeRvmToken != null &&
//                         _timeLeft.inSeconds > 0 &&
//                         !_isGeneratingNewToken)
//                     ? OutlinedButton.icon(
//                       icon: const Icon(Icons.timer_outlined, size: 20),
//                       label: Text(
//                         "${_timeLeft.inMinutes.toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}",
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onPressed: null, // Disabled saat timer berjalan
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: BorderSide(
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.primary.withOpacity(0.5),
//                         ),
//                       ),
//                     )
//                     : ElevatedButton.icon(
//                       icon: const Icon(Icons.qr_code_scanner_rounded),
//                       label: const Text("Generate Ulang Kode"),
//                       onPressed:
//                           _isGeneratingNewToken
//                               ? null
//                               : _handleGenerateNewToken,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         textStyle: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//           ),
//         ],
//       ),
//     );
//   }
// }
