# [Flutter User App] Desain Interaksi untuk Menampilkan QR Code Deposit RVM

Dokumen ini menganalisis dan memberikan rekomendasi untuk desain antarmuka pengguna (UI) dan pengalaman pengguna (UX) terkait cara menampilkan QR Code token deposit RVM di Aplikasi User Flutter. Tujuannya adalah agar pengguna mudah mendapatkan dan menggunakan kode QR, serta memahami masa berlakunya.

## Konteks Masalah

Setelah pengguna login ke Aplikasi User, mereka memerlukan cara untuk men-generate token RVM sementara yang akan ditampilkan sebagai QR Code. QR Code ini kemudian akan dipindai oleh mesin RVM fisik untuk mengotentikasi sesi deposit pengguna. Diperlukan transisi yang jelas dari kondisi "tidak ada QR" ke "QR ditampilkan" dan kembali lagi setelah QR tidak valid atau timer habis.

## Analisis Ide Awal dan Rekomendasi

### Ide 1: Tombol FAB (Floating Action Button) -> Popup/Modal Penuh dengan QR Code

*   **Alur:**
    1.  Pengguna berada di `HomeScreen`.
    2.  Terdapat sebuah FAB (misalnya, dengan ikon QR) di posisi standar (kanan bawah atau tengah bawah).
    3.  Saat FAB ditekan:
        *   Aplikasi menampilkan indikator loading.
        *   Memanggil API backend untuk men-generate `rvm_login_token`.
        *   Setelah token diterima, tampilkan **popup penuh atau modal bottom sheet** yang berisi:
            *   Gambar QR Code besar yang dihasilkan dari token.
            *   Timer mundur visual (misalnya, "Berlaku selama 04:59").
            *   Instruksi singkat ("Scan kode ini di mesin RVM").
            *   Tombol "Tutup" atau ikon "X" untuk menutup modal secara manual.
    4.  Jika timer habis atau modal ditutup manual, popup menghilang.
    5.  Jika FAB ditekan lagi, selalu generate token baru dan tampilkan di popup baru.
*   **Kelebihan:**
    *   **Aksi Jelas & Fokus:** Pengguna secara eksplisit meminta QR, dan popup memberikan fokus penuh pada QR tersebut.
    *   **UI `HomeScreen` Bersih:** QR tidak memakan ruang permanen di layar utama.
    *   **Kontrol Pengguna:** Tombol tutup manual.
    *   **Token Selalu Fresh:** Setiap permintaan FAB menghasilkan token baru.
*   **Kekurangan/Pertimbangan:**
    *   Implementasi UI popup/modal dan timer di dalamnya memerlukan perhatian khusus pada manajemen state dan siklus hidup widget modal.
    *   Popup penuh mungkin terasa sedikit "mengganggu" jika pengguna sering melakukannya.
*   **Sample Widget (Konsep untuk Modal Bottom Sheet):**
    ```dart
    // Di dalam _HomeScreenState, setelah token didapat:
    // void _showQrModal(String tokenData) {
    //   showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     builder: (BuildContext bc) {
    //       return StatefulBuilder( // Untuk timer di dalam modal
    //         builder: (BuildContext context, StateSetter modalSetState) {
    //           // ... (Implementasi UI Modal dengan QrImageView, Timer, Tombol Tutup) ...
    //           // Contoh:
    //           // Duration timeLeft = const Duration(minutes: 5);
    //           // Timer? countdownTimer;
    //           // void startTimer() { /* ... logika timer ... */ }
    //           // useEffect(() { startTimer(); return () => countdownTimer?.cancel(); }, []); // Mirip componentDidMount & WillUnmount
    //           
    //           return Container(
    //             padding: const EdgeInsets.all(20),
    //             child: Wrap(children: <Widget>[
    //               // ... Judul, Tombol Tutup ...
    //               QrImageView(data: tokenData, size: 200.0),
    //               // ... Timer Text ...
    //             ]),
    //           );
    //         },
    //       );
    //     },
    //   );
    // }
    ```

### Ide 2: Placeholder Gambar QR Code Dummy -> Update di Tempat, Kembali ke Placeholder Setelah Timer

*   **Alur:**
    1.  `HomeScreen` menampilkan area khusus dengan gambar QR code placeholder (misalnya, QR abu-abu atau pesan "Tekan untuk Generate").
    2.  Terdapat tombol "Generate Kode Deposit" di dekatnya.
    3.  Saat tombol ditekan:
        *   Tampilkan loading di area placeholder.
        *   Panggil API untuk generate token.
        *   Ganti placeholder dengan QR code asli di area yang sama.
        *   Tampilkan timer mundur di dekat QR.
    4.  Setelah timer habis, area tersebut kembali menampilkan placeholder.
    5.  Menekan tombol "Generate" lagi akan mengulang proses dengan token baru.
*   **Kelebihan:**
    *   **Area QR Selalu Terlihat:** Memberi petunjuk visual yang konsisten.
    *   **Transisi In-Page:** Tidak ada popup yang menutupi layar.
*   **Kekurangan/Pertimbangan:**
    *   **Potensi Kebingungan Jika Auto-Refresh:** Jika ada logika auto-refresh QR (bukan hanya kembali ke placeholder), bisa membingungkan pengguna yang akan scan.
    *   Memakan ruang UI permanen di `HomeScreen` untuk area QR, meskipun sedang tidak aktif.
*   **Sample Widget (Konsep untuk Area QR In-Page):**
    ```dart
    // Di _HomeScreenState
    // String? _activeRvmToken;
    // Timer? _qrTokenTimer;
    // Duration _timeLeft = const Duration(minutes: 5);

    // void _startQrTimer() { /* ... logika timer untuk mengubah _activeRvmToken jadi null ... */ }
    // void _generateAndDisplayToken() { /* ... panggil API, set _activeRvmToken, panggil _startQrTimer ... */ }

    // Di build() method:
    // Container(
    //   height: 250, width: 250,
    //   child: _activeRvmToken != null
    //       ? Column(children: [ QrImageView(data: _activeRvmToken!), Text("Berlaku: ...") ])
    //       : Center(child: Text("Tekan Generate untuk menampilkan QR")),
    // ),
    // ElevatedButton(onPressed: _generateAndDisplayToken, child: Text("Generate Kode")),
    ```

### Rekomendasi Kombinasi (Pilihan Terbaik Saat Ini)

Menggabungkan Ide 1 (aksi eksplisit) dengan Ide 2 (tampilan in-page tanpa popup penuh yang mengganggu) untuk UX yang lebih halus, dan memastikan QR kembali ke placeholder setelah timer.

*   **Alur yang Diimplementasikan (dan Disempurnakan):**
    1.  **`HomeScreen` Tampilan Awal:**
        *   Terdapat area khusus (misalnya, `Container` atau `Card`) yang menampilkan **gambar QR code placeholder** atau pesan seperti "Tekan 'Generate Kode Deposit' untuk memulai".
        *   Di bawah atau di dekat area ini, ada tombol `ElevatedButton` bertuliskan "Generate Kode Deposit".
    2.  **Pengguna Menekan Tombol "Generate Kode Deposit":**
        *   State `_isGeneratingToken` diset `true` (untuk menampilkan `CircularProgressIndicator` di area QR atau di atas tombol).
        *   Panggil `_authService.generateRvmLoginToken()`.
        *   Setelah token diterima (`_activeRvmToken` diset dengan data token baru):
            *   State `_isGeneratingToken` diset `false`.
            *   Area placeholder diganti dengan `QrImageView` yang menampilkan QR code asli.
            *   Timer mundur visual (`_timeLeft`) ditampilkan di dekat QR code.
            *   Timer internal (`_qrTokenTimer` dari `dart:async`) dimulai (misalnya, 5 menit).
    3.  **Setelah Timer Habis:**
        *   Callback timer akan men-set `_activeRvmToken = null`.
        *   `setState` dipanggil, sehingga area QR code kembali menampilkan gambar placeholder.
        *   Tombol "Generate Kode Deposit" kembali aktif sepenuhnya.
    4.  **Menekan Tombol "Generate Kode Deposit" Lagi:**
        *   Akan selalu membatalkan timer lama (jika ada), men-generate token BARU dari API, menampilkan QR baru, dan memulai timer baru.
*   **Kelebihan Pendekatan Ini:**
    *   **UX Halus:** Tidak ada popup penuh, transisi terjadi di tempat yang sudah dikenal pengguna.
    *   **Informasi Jelas:** Pengguna tahu di mana QR akan muncul dan melihat timer masa berlaku.
    *   **Kontrol Pengguna:** Aksi generate eksplisit.
    *   **Token Selalu Fresh:** Setiap generate menghasilkan token baru.
*   **Implementasi:** Menggunakan `setState` untuk mengontrol widget mana yang ditampilkan di area QR (`QrImageView` atau Placeholder) berdasarkan apakah `_activeRvmToken` berisi data atau `null`. Timer `dart:async` digunakan untuk mengontrol `_activeRvmToken` kembali ke `null`.

---

## Tambahan: Mengontrol Kecerahan Layar Handphone Saat QR Tampil

*   **Tujuan:** Meningkatkan keterbacaan QR code oleh mesin RVM dengan memaksimalkan kecerahan layar HP pengguna saat QR ditampilkan.
*   **Kemungkinan:** YA, dengan batasan.
*   **Cara:** Menggunakan package Flutter pihak ketiga seperti `screen_brightness` atau `flutter_screen_brightness`.
*   **Alur Implementasi:**
    1.  Tambahkan package ke `pubspec.yaml`.
    2.  Saat QR code akan ditampilkan (setelah token diterima dan sebelum `QrImageView` dirender):
        *   Simpan tingkat kecerahan layar saat ini: `_currentBrightness = await screenBrightness.current;`
        *   Setel kecerahan layar ke maksimum: `await screenBrightness.setScreenBrightness(1.0);`
    3.  Saat QR code disembunyikan (timer habis atau area QR kembali ke placeholder):
        *   Kembalikan kecerahan layar ke tingkat semula: `await screenBrightness.setScreenBrightness(_currentBrightness);`
*   **Pertimbangan:**
    *   **Izin Pengguna:** Mungkin memerlukan izin khusus.
    *   **Perilaku Platform:** Bisa sedikit berbeda antar OS.
    *   **UX:** Informasikan pengguna atau berikan opsi jika kecerahan layar akan diubah secara otomatis.

---