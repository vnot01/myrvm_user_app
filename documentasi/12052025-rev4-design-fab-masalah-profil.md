# [Flutter User App] Revisi ke-4: Desain UI/UX, Fungsionalitas, dan Troubleshooting

Dokumen ini merangkum diskusi, keputusan desain, implementasi, dan solusi troubleshooting untuk Aplikasi User Flutter dalam sistem RVM. Fokus utama adalah pada alur autentikasi, tampilan profil, dan mekanisme generate QR Code untuk deposit.

**Progres Pengembangan Aplikasi User (Flutter): ~80% Selesai**
*(Fungsionalitas inti seperti login, registrasi, tampilan profil dasar, logout, dan generate QR code dasar sudah berjalan)*

## I. Desain Interaksi dan Fungsionalitas Utama yang Disepakati

### A. Struktur Aplikasi Utama (`MainShellScreen`)
1.  **Tujuan:** Menyediakan kerangka navigasi utama aplikasi setelah pengguna login.
2.  **Implementasi:** Menggunakan `Scaffold` dengan `BottomAppBar` yang memiliki lekukan (`CircularNotchedRectangle`) dan `FloatingActionButton` (FAB) yang ditempatkan di tengah bawah (`FloatingActionButtonLocation.centerDocked`).
3.  **Navigasi Tab:** `BottomAppBar` berisi `IconButton` untuk navigasi ke layar-layar utama (Home, Statistik, Riwayat, Profil). State tab aktif dikelola oleh `_currentIndex` di `MainShellScreen`. `body` dari `Scaffold` menampilkan layar yang sesuai menggunakan `IndexedStack` (untuk menjaga state tab) atau dengan memilih widget dari list.
4.  **FAB "QR":**
    *   **Visual:** Berbentuk lingkaran, berisi `Column` dengan `Icon(Icons.qr_code_scanner_rounded)` di atas dan teks "QR" di bawahnya. Ukuran disesuaikan agar seimbang dengan lekukan `BottomAppBar`.
    *   **Aksi:** Menekan FAB ini akan memicu alur untuk menampilkan Modal Bottom Sheet berisi QR Code deposit. Akan selalu men-generate token BARU setiap kali ditekan.

### B. Tampilan QR Code Deposit (via Modal Bottom Sheet)
1.  **Pemicu:** FAB "QR" di `MainShellScreen`.
2.  **Alur Tampilan Modal:**
    *   Setelah FAB ditekan, tampilkan indikator loading singkat.
    *   Panggil API backend (`/api/user/generate-rvm-token`) untuk mendapatkan `rvm_login_token`.
    *   Jika token berhasil didapat:
        *   Minta izin pengguna untuk meningkatkan kecerahan layar (jika belum pernah diizinkan di sesi ini).
        *   Jika diizinkan, simpan kecerahan awal, lalu maksimalkan kecerahan layar.
        *   Tampilkan **Modal Bottom Sheet** (`QrModalSheetWidget`).
    *   Jika gagal mendapatkan token: Tampilkan `SnackBar` error.
3.  **Desain `QrModalSheetWidget`:**
    *   **Struktur:** Widget `StatefulWidget` untuk mengelola state internal (timer, data QR).
    *   **Tombol Tutup:** Ikon "X" di pojok kanan atas modal untuk menutup manual.
    *   **Judul:** Teks seperti "Kode QR Deposit Anda".
    *   **Area QR Code:**
        *   Jika token aktif dan timer berjalan: Menampilkan `QrImageView` dengan token.
        *   Jika token expired/tidak aktif: Menampilkan placeholder (ikon QR abu-abu dan teks "Tekan 'Generate Ulang Kode'...").
    *   **Teks Instruksi:** Di bawah QR, teks "Arahkan kode ini ke kamera mesin RVM..."
    *   **Tombol Bawah Dinamis (Menggantikan satu sama lain):**
        *   **Saat QR Aktif & Timer Berjalan:** Area ini menampilkan teks timer mundur ("Berlaku: MM:SS") dengan ikon jam. Area ini **disabled** (tidak bisa diklik).
        *   **Saat Timer Habis/QR Expired:** Area ini berubah menjadi tombol **aktif** dengan ikon QR dan teks "Generate Ulang Kode".
    *   **Aksi Tombol "Generate Ulang Kode":**
        1.  Menampilkan loading di dalam modal.
        2.  Meminta izin kecerahan lagi (jika perlu).
        3.  Memanggil API `/api/user/generate-rvm-token` untuk mendapatkan token BARU.
        4.  Jika sukses: Update `QrImageView` dengan token baru, reset dan mulai ulang timer 5 menit, mulai ulang polling status scan. Kecerahan disesuaikan.
        5.  Jika gagal: Tampilkan error di modal, tombol kembali ke "Generate Ulang Kode".
4.  **Timer Internal Modal:** 5 menit. Setelah habis, QR menjadi placeholder dan tombol menjadi "Generate Ulang Kode".
5.  **Penutupan Modal (Tombol X, Swipe-down, atau setelah Scan Sukses):**
    *   Timer dan polling dihentikan.
    *   Kecerahan layar dikembalikan ke tingkat semula (jika sebelumnya diubah oleh aplikasi).
    *   Jika modal ditutup karena "Scan Sukses" (dari polling), Aplikasi User akan me-refresh data pengguna (poin, riwayat).

### C. Kontrol Kecerahan Layar
1.  **Pemicu:** Saat FAB "QR" ditekan atau tombol "Generate Ulang Kode" di modal ditekan, sebelum QR ditampilkan.
2.  **Izin Pengguna:** Tampilkan `AlertDialog` untuk meminta izin meningkatkan kecerahan. Pilihan: "Tolak", "Izinkan". Status izin bisa disimpan untuk sesi aplikasi.
3.  **Aksi:** Jika diizinkan, simpan kecerahan awal, lalu naikkan ke maksimum menggunakan package `screen_brightness`.
4.  **Pengembalian:** Kecerahan dikembalikan ke normal saat modal QR ditutup.

### D. Notifikasi Sukses Scan (via Polling)
1.  **Pemicu:** Setelah QR Code ditampilkan di `QrModalSheetWidget`.
2.  **Proses:** Aplikasi User mulai polling ke endpoint backend `/api/user/check-rvm-scan-status?token=<rvm_login_token>` setiap 7-10 detik.
3.  **Respons Backend:**
    *   `{"status": "pending_scan"}`: Polling dilanjutkan.
    *   `{"status": "scanned_and_validated"}`: Token telah berhasil divalidasi oleh RVM.
    *   `{"status": "token_expired_or_invalid"}`: Token sudah tidak valid.
4.  **Aksi di Aplikasi User (jika `scanned_and_validated`):**
    *   Hentikan timer QR dan polling.
    *   Tampilkan dialog popup "Scan Berhasil!".
    *   Setelah dialog sukses ditutup, tutup juga modal QR.
    *   (Otomatis) Refresh data pengguna (poin, riwayat) di `HomeScreen` atau `ProfileScreen`.

### E. Tampilan `HomeScreen`
1.  Menampilkan ucapan "Selamat Datang, [Nama User]!" (nama diambil dari `TokenService` atau API profil).
2.  Konten utama bisa berupa ringkasan poin, aktivitas terakhir, atau navigasi lain. Area QR tidak lagi permanen di sini, dipicu oleh FAB.

### F. `ProfileScreen`
1.  Menggunakan `FutureBuilder` untuk mengambil dan menampilkan data profil pengguna dari API `/api/auth/user`.
2.  Menampilkan semua detail pengguna yang relevan (Nama, Email, Poin, Role, No. Telepon, dll.).
3.  Menyediakan tombol Logout dengan dialog konfirmasi.
4.  Memiliki fitur "Tarik untuk Refresh" (`RefreshIndicator`).

## Troubleshooting dan Solusi yang Diterapkan

1.  **Masalah: Tombol "Back" di `LoginScreen` kembali ke `AuthCheckScreen` (Splash).**
    *   **Penyebab:** Penggunaan `Navigator.pushReplacementNamed` mungkin tidak selalu membersihkan stack secara sempurna dalam semua skenario hot reload/restart atau setelah `SystemNavigator.pop()`.
    *   **Solusi Diterapkan:** Menggunakan `Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainShellScreen()), (Route<dynamic> route) => false,);` untuk semua navigasi ke `MainShellScreen` atau `LoginScreen` dari `AuthCheckScreen` dan setelah aksi login/registrasi/logout. Ini memastikan tumpukan navigasi selalu bersih. `PopScope` dengan `canPop: false` juga ditambahkan ke `LoginScreen` dan `MainShellScreen` untuk mengontrol tombol back fisik.

2.  **Masalah: `ProfileScreen` menampilkan "N/A" meskipun API mengembalikan data.**
    *   **Penyebab:** Kesalahan dalam cara `FutureBuilder` atau `setState` menangani dan mengakses data dari `snapshot.data` (seluruh respons API vs objek user di dalamnya).
    *   **Solusi Diterapkan:** Memastikan `AuthService.getUserProfile()` mengembalikan objek user `Map<String, dynamic>?` secara langsung. `FutureBuilder` di `ProfileScreen` kemudian menggunakan `snapshot.data` yang sudah merupakan objek user.

3.  **Masalah: `NoSuchMethodError: The method '[]' was called on null` di `AuthService` saat login/register gagal.**
    *   **Penyebab:** Kode mencoba mengakses key (seperti `message` atau `errors`) pada `responseData` yang mungkin `null` jika respons API tidak sukses atau bukan JSON.
    *   **Solusi Diterapkan:** Menambahkan pengecekan null yang lebih aman (`responseData != null && responseData['key'] != null`) dan penggunaan safe access operator (`?`) sebelum mengakses elemen map di `AuthService`.

4.  **Masalah: Tampilan Web Laravel via `ngrok` berantakan (CSS/JS tidak termuat).**
    *   **Penyebab:** `APP_URL` di `.env` Laravel tidak disetel ke URL `ngrok` HTTPS, menyebabkan URL aset salah.
    *   **Solusi Diterapkan:** Memastikan `APP_URL` di `.env` Laravel menggunakan URL `ngrok` HTTPS lengkap, lalu menjalankan `php artisan optimize:clear`.

5.  **Masalah: `WillPopScope` deprecated.**
    *   **Solusi Diterapkan:** Menggantinya dengan `PopScope` dan menggunakan callback `onPopInvokedWithResult`.

6.  **Masalah: Import `foundation.dart` atau `services.dart` yang tidak perlu jika `material.dart` sudah ada.**
    *   **Solusi Diterapkan:** Menghapus import yang redundan dan mengandalkan ekspor ulang simbol dari `material.dart`.

## Catatan Tambahan

*   **Kecerahan Layar:** Implementasi kontrol kecerahan layar akan menggunakan package `screen_brightness`. Izin pengguna akan diminta.
*   **Error Handling:** Penanganan error pada panggilan API dan operasi internal terus disempurnakan dengan `try-catch` dan pesan yang informatif.
*   **Logging:** `debugPrint()` digunakan secara ekstensif untuk debugging di Flutter.
*   **Konsistensi Kode:** Upaya untuk menjaga konsistensi dalam penamaan, struktur, dan penggunaan blok `if/else`.

Dengan revisi desain ini, Aplikasi User akan memiliki alur yang lebih matang, UX yang lebih baik, dan lebih fokus pada fungsionalitas inti yang dibutuhkan pengguna RVM.