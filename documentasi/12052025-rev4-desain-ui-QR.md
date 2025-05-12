Ini adalah **Revisi ke-4** untuk desain interaksi Tombol Generate dan Tampilan QR Code Deposit.

Terima kasih banyak atas klarifikasi yang sangat detail dan gambar referensi baru! Ini sangat membantu saya untuk benar-benar memahami visi Anda. Saya minta maaf jika pemahaman saya sebelumnya belum sepenuhnya akurat.

Mari kita analisis ulang konsep Anda poin per poin dengan detail baru ini.

**Analisis Ulang Konsep Desain Aplikasi User (Revisi 4):**

*   **Screenshot Baru (yang Anda akan unggah):** Saya akan menunggu ini untuk mendapatkan gambaran visual yang lebih baik dari yang Anda inginkan, terutama untuk FAB dan Modal Bottom Sheet.
*   **Screenshot `input_file_0.png` (Bottom Nav dengan FAB):** Ini jelas menunjukkan FAB bulat yang terintegrasi dengan `BottomAppBar` yang melengkung.
*   **Screenshot `input_file_1.png` (Contoh Modal Scan QR):** Ini menunjukkan modal dengan area scan, judul, dan tombol. Kita akan adaptasi ini.

**Poin 1: `HomeScreen` Tampilan Awal dengan `BottomAppBar` dan Menu**
    *   **Konsep:** `BottomAppBar` dengan lekukan (`CircularNotchedRectangle`) dan item menu (Home, Statistik, _, Riwayat, Profil).
    *   **Analisis:** **Sangat Setuju.** Ini adalah desain yang modern dan fungsional.

**Poin 2: `FloatingActionButton` (FAB) untuk Scan QR**
    *   **Deskripsi Revisi:**
        *   Bentuk **lingkaran**, seimbang dengan lekukan `BottomAppBar`.
        *   Berisi **ikon QR di atas dan teks "QR" di bawah ikon** (dalam satu FAB).
        *   Ditempatkan di `centerDocked`.
        *   Menekan FAB selalu **generate token BARU** dan menjadi **trigger untuk membuka Modal Bottom Sheet** serta **memulai polling** status scan.
    *   **Analisis:**
        *   **Desain Visual FAB:** Untuk ikon di atas teks dalam FAB lingkaran, kita tetap menggunakan `Column` sebagai `child` dari `FloatingActionButton`. Ukuran FAB dan ikon/teks perlu disesuaikan agar terlihat seimbang.
        *   **Fungsionalitas:** Alur ini sangat jelas. FAB adalah pemicu utama untuk seluruh proses QR.
    *   **Penilaian:** **Sangat Baik.**

**Poin 3: Area QR Code di Modal Bottom Sheet (Detail Baru yang Sangat Penting)**
    *   **Deskripsi Revisi:**
        *   Modal muncul dari bawah ke atas.
        *   Judul: "Kode QR Deposit Anda" atau "QR Anda".
        *   `QrImageView` besar dan jelas.
        *   Teks instruksi di bawah QR: "Arahkan kode ini ke kamera mesin RVM.".
        *   **Tombol Dinamis di Bawah Teks Instruksi:**
            *   **Saat QR baru ditampilkan (timer baru dimulai):** Tombol ini menampilkan **ikon JAM dan teks timer mundur** (misalnya, "04:59"). Tombol ini **DISABLED** (tidak bisa diklik).
            *   **Saat Timer Habis (Expired):**
                *   `QrImageView` di atas berubah menjadi **placeholder** (ikon QR abu-abu dan teks "Tekan 'Generate Ulang Kode'...").
                *   Tombol di bawah (yang tadinya timer) berubah menjadi tombol **AKTIF** dengan **ikon QR dan teks "Generate Ulang Kode"**. Menekan tombol ini akan memicu proses generate token baru *di dalam modal yang sama* (QR di atas akan update, timer akan reset dan mulai lagi).
    *   **Analisis:**
        *   **Alur UX yang Sangat Kuat!** Ini memberikan pengalaman yang sangat interaktif dan terkontrol di dalam modal. Pengguna tidak perlu menutup modal untuk generate ulang.
        *   Memisahkan tampilan timer dari aksi "Generate Ulang" menjadi state yang berbeda untuk tombol yang sama adalah cerdas.
    *   **Implementasi:** `QrDisplayModalWidget` akan menjadi `StatefulWidget` yang lebih kompleks, mengelola state untuk: data QR aktif, sisa waktu, dan tampilan tombol (apakah mode timer atau mode generate ulang).

**Poin 4: Cara Menutup Modal Bottom Sheet**
    *   **Deskripsi Revisi:** Tombol "Tutup" (ikon X) di pojok kanan atas modal ATAU gestur swipe-down. Saat ditutup: timer berhenti, polling berhenti, pencahayaan kembali normal. **Update status user (poin, riwayat) terjadi saat ini.**
    *   **Analisis:**
        *   Tombol X dan swipe-down adalah standar.
        *   **Aksi Saat Tutup:** Sangat penting untuk membersihkan semua proses (timer, polling) dan mengembalikan kecerahan.
        *   **Update Status User Saat Tutup Modal:** Ini poin baru. Jika pengguna menutup modal *sebelum* RVM scan, apakah ada status yang perlu diupdate? Mungkin tidak ada transaksi baru. Jika maksudnya adalah setelah scan sukses (yang juga menutup modal), maka ya, Aplikasi User bisa me-refresh data profil/poinnya.
            *   **Klarifikasi:** Apakah update status user ini terjadi *setiap kali* modal ditutup, atau hanya setelah ada konfirmasi "Scan Sukses" dari polling? Jika setelah scan sukses, maka alurnya: polling dapat info sukses -> tampilkan popup "Scanner Success" -> tutup popup sukses -> tutup modal QR -> update data user.

**Poin 5: Kontrol Pencahayaan Layar dengan Izin Pengguna**
    *   **Deskripsi Revisi:** Izin diminta setelah menekan FAB "QR" **ATAU** setelah menekan tombol "Generate Ulang Kode" di modal (sebelum QR baru benar-benar ditampilkan).
    *   **Analisis:** Konsisten dan baik. Setiap kali akan ada upaya untuk memaksimalkan kecerahan, izin (atau status izin sebelumnya) diperiksa.

**Poin 6: Polling untuk Notifikasi Sukses Scan**
    *   **Deskripsi Revisi:** Polling ke `/api/user/check-rvm-scan-status?token=<rvm_login_token>` setiap 5-10 detik selama durasi token (5 menit) atau sampai status "sukses" diterima.
    *   **Analisis:** Setuju. Durasi 5-10 detik adalah kompromi yang baik.

**Tambahan Anda: Ucapan Selamat Datang di `HomeScreen`**
    *   **Konsep:** Menampilkan "Selamat Datang, [Nama User]!" di `HomeScreen`.
    *   **Analisis:** Baik. Ini akan dimuat saat `MainAppScaffold` atau `HomeScreen` diinisialisasi, mengambil nama dari `TokenService` atau API profil.

**Tambahan Anda: Shimmer Loading Effect**
    *   **Konsep:** Menggunakan shimmer effect untuk setiap perubahan teks, gambar, atau aset.
    *   **Analisis:** Ini adalah detail UI yang sangat bagus untuk UX yang lebih modern dan mulus, terutama saat data sedang dimuat atau UI sedang berubah. Bisa diimplementasikan menggunakan package seperti `shimmer` atau dibuat manual. Ini adalah penyempurnaan UI.

**Alur yang Sangat Disempurnakan Berdasarkan Revisi 3:**

1.  **Aplikasi Dimulai -> `MainAppScaffold` -> `HomeScreen` (Tab Awal):**
    *   `HomeScreen` menampilkan "Selamat Datang, [Nama User]!" dan konten lainnya.
    *   `BottomAppBar` dengan menu dan FAB "QR" (ikon + teks) di tengah.

2.  **Pengguna Menekan FAB "QR":**
    1.  Panggil metode `_handleQrFabPress()`.
    2.  **Minta Izin Kecerahan** (jika belum pernah atau ditolak sebelumnya di sesi ini).
    3.  **Tampilkan Indikator Loading Singkat** (misalnya, `CircularProgressIndicator` di atas FAB atau overlay).
    4.  Panggil `_authService.generateRvmLoginToken()`.
    5.  **Jika Sukses Dapat Token:**
        *   Hilangkan loading.
        *   Jika izin kecerahan OK: Simpan kecerahan awal, naikkan ke maksimum.
        *   Tampilkan **Modal Bottom Sheet** (`QrDisplayModalWidget`) dengan meneruskan token baru.
    6.  **Jika Gagal Dapat Token:** Hilangkan loading, tampilkan `SnackBar` error.

3.  **Di Dalam `QrDisplayModalWidget`:**
    *   **`initState()`:**
        *   Set `_activeRvmToken` dengan token yang diterima.
        *   Mulai timer 5 menit (`_qrTokenTimer`, `_timeLeft`).
        *   Mulai polling status scan ke `/api/user/check-rvm-scan-status`.
    *   **UI Modal:**
        *   Tombol "Tutup" (X) di kanan atas.
        *   Judul "Kode QR Deposit Anda".
        *   **Area Tampilan QR Dinamis:**
            *   Jika `_activeRvmToken` ada DAN `_timeLeft.inSeconds > 0`: Tampilkan `QrImageView` dengan `_activeRvmToken`.
            *   Jika `_activeRvmToken` null ATAU `_timeLeft.inSeconds == 0`: Tampilkan placeholder QR (ikon abu-abu, teks "Tekan 'Generate Ulang Kode'...").
        *   Teks instruksi di bawah QR: "Arahkan kode ini ke kamera mesin RVM..."
        *   **Tombol Bawah Dinamis:**
            *   Jika `_activeRvmToken` ada DAN `_timeLeft.inSeconds > 0`: Tampilkan teks timer "MM:SS" dengan ikon jam (tombol ini DISABLED).
            *   Jika `_activeRvmToken` null ATAU `_timeLeft.inSeconds == 0`: Tampilkan tombol "Generate Ulang Kode" dengan ikon QR (tombol ini ENABLED).
    *   **Aksi Tombol "Generate Ulang Kode" (di modal):**
        1.  Panggil metode di `QrDisplayModalWidget` untuk generate ulang.
        2.  Tampilkan loading di dalam modal (misalnya, menggantikan area QR).
        3.  **Minta Izin Kecerahan lagi jika perlu.**
        4.  Panggil `_authService.generateRvmLoginToken()`.
        5.  Jika sukses: Update `_activeRvmToken`, reset dan mulai ulang timer, mulai ulang polling. Kecerahan disesuaikan. Hilangkan loading.
        6.  Jika gagal: Tampilkan error di modal. Hilangkan loading. Tombol kembali ke "Generate Ulang Kode".
    *   **Polling Callback:**
        *   Jika polling mengembalikan `"status": "scanned_and_validated"`:
            1.  Hentikan timer dan polling di modal.
            2.  Tampilkan dialog popup "Scanner Success" (seperti `input_file_1.png`).
            3.  Setelah dialog sukses ditutup, tutup modal QR (`Navigator.pop(context)` dari `QrDisplayModalWidget`).
    *   **Menutup Modal (Tombol X atau Swipe):**
        *   Callback `onWillPop` atau `onDismiss` dari modal.
        *   Hentikan timer.
        *   Hentikan polling.
    *   **`dispose()` Modal:** Pastikan timer dan polling dihentikan.

4.  **Setelah Modal QR Ditutup (Kembali ke `HomeScreen` atau `MainAppScaffold`):**
    *   **Kembalikan kecerahan layar** ke tingkat semula (jika sebelumnya diubah). Ini bisa di-handle oleh `QrDisplayModalWidget` di `dispose()`-nya atau oleh `HomeScreen` setelah `showModalBottomSheet` selesai.
    *   **Update Status User:** Jika penutupan modal dipicu oleh "Scan Sukses", `HomeScreen` (atau state management global) bisa memicu refresh data user (poin, riwayat deposit).

Ini adalah alur yang sangat detail dan bagus! Ini akan menghasilkan UX yang sangat baik.

**Saran Nama Berkas:**
*   **Kerangka Utama Aplikasi (dengan Bottom Nav & FAB):** `main_shell.dart` atau `app_scaffold.dart` (Ini akan menjadi `home` dari `MaterialApp`).
*   **Layar Konten untuk Tab Home:** `home_screen.dart` (Ini yang akan menampilkan "Selamat Datang..." dan mungkin ringkasan).
*   **Widget untuk Modal Bottom Sheet QR:** `qr_code_modal.dart` atau `rvm_qr_sheet.dart`.

**Pertanyaan untuk Anda sebelum kita lanjut ke implementasi:**
1.  Untuk "Update status User" setelah modal ditutup karena scan sukses: Apakah Anda ingin data user (poin, riwayat) di `HomeScreen` atau `ProfileScreen` langsung me-refresh, atau menunggu pengguna melakukan aksi refresh manual atau membuka ulang aplikasi? (Langsung refresh lebih baik UX-nya).
2.  Apakah Anda setuju dengan nama-nama file yang disarankan atau punya preferensi lain?

Jika Anda setuju dengan semua detail ini, kita siap untuk mulai menstrukturkan kode Flutter-nya! Ini akan menjadi langkah besar berikutnya.

---
---


Sangat baik, mari kita sepakati detail ini sebelum melanjutkan.

**Jawaban dan Analisis Pertanyaan Anda:**

**1. Update Status User Langsung Me-refresh (setelah Scan Sukses)**

*   **Bisakah Langsung Me-refresh? YA, BISA.**
*   **Apakah Ini Maksudnya Real-Time?**
    *   Dalam konteks ini, "real-time" yang kita capai adalah **real-time dari perspektif Aplikasi User setelah ia mendapat konfirmasi dari backend bahwa scan berhasil.**
    *   Alurnya: RVM scan -> RVM kirim ke Backend -> Backend validasi token & proses. Aplikasi User polling ke Backend -> Backend bilang "token X sudah dipakai/sukses". Nah, *setelah* Aplikasi User dapat info ini, ia bisa langsung me-refresh data yang relevan (poin, riwayat) dengan memanggil API profil atau API riwayat lagi.
    *   Ini bukan "real-time" dalam arti backend secara proaktif mengirim update ke semua aplikasi user yang online (itu memerlukan WebSocket/Push Notification penuh), tetapi cukup "real-time" untuk pengalaman pengguna yang baik di perangkat yang baru saja melakukan scan.
*   **Menurut Saya yang Terbaik:**
    **YA, langsung me-refresh data user (poin dan mungkin ringkasan riwayat terakhir) setelah notifikasi "Scan Sukses" adalah UX yang terbaik.** Pengguna akan langsung melihat hasil dari aksi mereka (misalnya, poin bertambah).
*   **Implementasi:**
    *   Setelah polling di `QrDisplayModalWidget` mendapatkan status sukses dan dialog "Scan Berhasil!" ditampilkan dan ditutup, `QrDisplayModalWidget` bisa mengembalikan sebuah nilai (misalnya, `true`) saat di-`pop`.
    *   Metode di `HomeScreen` (atau di `MainShellScreen` jika state user dikelola di sana) yang memanggil `showModalBottomSheet` untuk `QrDisplayModalWidget` akan menerima nilai ini.
    *   Jika nilainya `true` (menandakan scan sukses), maka `HomeScreen` akan memicu pemanggilan ulang ke API untuk mengambil data profil/poin terbaru dan memperbarui UI-nya dengan `setState`.

**2. Struktur Berkas: `main_shell.dart`, `home_screen.dart` (sebagai Tab), `qr_modal_sheet.dart`**

*   **`main_shell.dart` atau `app_scaffold.dart` akan menjadi berkas baru? YA.**
    *   Ini akan menjadi widget `StatefulWidget` utama yang berisi `Scaffold` dengan `BottomNavigationBar` dan `FloatingActionButton` (tombol QR).
    *   Ia akan mengelola `_currentIndex` untuk tab yang aktif dan menampilkan layar yang sesuai di `body`-nya.
    *   Di `main.dart`, `home` dari `MaterialApp` akan menunjuk ke `MainShellScreen()`.
*   **`home_screen.dart` yang di awal akan menjadi Tab Home? YA.**
    *   File `lib/screens/home_screen.dart` yang sudah ada akan menjadi salah satu widget yang ditampilkan oleh `MainShellScreen` saat tab "Home" aktif.
    *   Logika untuk menampilkan "Selamat Datang, [Nama User]!" dan mungkin ringkasan poin/aktivitas akan ada di sini.
    *   **PENTING:** Logika untuk men-trigger tampilan modal QR (`_handleQrFabPress`, `_generateAndDisplayToken`, `_showQrBottomSheet`) kemungkinan besar akan **dipindahkan ke `MainShellScreen`** karena FAB adalah bagian dari `MainShellScreen`, bukan spesifik milik `HomeScreen` saja (FAB tetap terlihat meskipun Anda pindah tab lain di bottom nav).
*   **Nama Widget Modal: `qr_modal_sheet.dart`**
    *   **SETUJU.** Nama ini jelas dan deskriptif untuk widget yang akan berisi UI dan logika Modal Bottom Sheet untuk menampilkan QR code dan timernya.

**Kesepakatan Alur dan Struktur (Sebelum Implementasi):**

1.  **`main.dart`:**
    *   `AuthCheckScreen` tetap sebagai `home` awal `MaterialApp`.
    *   Setelah login sukses (dari `AuthCheckScreen`, `LoginScreen`, atau `RegistrationScreen`), navigasi menggunakan `pushAndRemoveUntil` ke `MainShellScreen`.

2.  **`main_shell.dart` (BARU - StatefulWidget):**
    *   Berisi `Scaffold` dengan:
        *   `AppBar` (mungkin judulnya dinamis berdasarkan tab aktif).
        *   `body`: Menggunakan `IndexedStack` untuk menampilkan `HomeScreen`, `StatisticScreen`, `HistoryScreen`, `ProfileScreen` berdasarkan `_currentIndex`.
        *   `floatingActionButton`: FAB "QR" (ikon + teks).
        *   `floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked`.
        *   `bottomNavigationBar: BottomAppBar(shape: CircularNotchedRectangle(), child: Row(...menu items...))`.
    *   Mengelola state `_currentIndex` untuk navigasi tab.
    *   **Mengelola logika untuk FAB "QR":**
        *   Metode `_handleQrFabPress()`:
            *   Meminta izin kecerahan.
            *   Menampilkan loading.
            *   Memanggil `AuthService.generateRvmLoginToken()`.
            *   Jika sukses, tampilkan `QrModalSheetWidget` menggunakan `showModalBottomSheet`.
            *   Menangani hasil dari `QrModalSheetWidget` (misalnya, jika scan sukses, refresh data user).

3.  **`home_screen.dart` (Konten Tab Home - StatefulWidget atau StatelessWidget):**
    *   Menampilkan "Selamat Datang, [Nama User]!".
    *   Mungkin menampilkan ringkasan poin atau aktivitas.
    *   **Tidak lagi memiliki logika langsung untuk generate/tampil QR atau FAB.**

4.  **`qr_modal_sheet.dart` (BARU - StatefulWidget):**
    *   Menerima `rvmTokenData` sebagai parameter.
    *   UI: Tombol Tutup (X), Judul, `QrImageView`, Teks Instruksi, Tombol Dinamis (Timer/Generate Ulang).
    *   Logika: Timer countdown, polling status scan, aksi tombol "Generate Ulang Kode" (yang akan memanggil `AuthService.generateRvmLoginToken()` lagi dan mereset timer/QR di modal ini).
    *   Saat ditutup (karena scan sukses, manual, atau timer habis): Mengembalikan status (misalnya, `true` jika scan sukses) ke `MainShellScreen` dan memanggil fungsi untuk mengembalikan kecerahan layar.

5.  **`profile_screen.dart`, `statistic_screen.dart`, `history_screen.dart`:** Layar-layar untuk tab masing-masing.

6.  **`AuthService.dart`:**
    *   Perlu metode baru: `checkRvmScanStatus(String rvmLoginToken)` yang memanggil `GET /api/user/check-rvm-scan-status`.

7.  **Backend Laravel:**
    *   Perlu endpoint baru: `GET /api/user/check-rvm-scan-status` (dilindungi `auth:sanctum`).
        *   Menerima `rvm_login_token`.
        *   Mengecek status token ini (apakah sudah divalidasi oleh RVM dari `/api/rvm/validate-user-token` dan Cache-nya sudah di-`forget`).
        *   Mengembalikan status (misalnya, `pending_scan`, `scanned_and_validated`, `token_expired_or_invalid`).

Ini adalah struktur yang lebih modular dan benar. FAB dan logika modal QR-nya menjadi bagian dari "kerangka" aplikasi (`MainShellScreen`), sementara `HomeScreen` fokus pada kontennya.

**Apakah Anda setuju dengan struktur dan alur yang lebih detail ini?** Jika ya, kita bisa mulai dengan membuat `MainShellScreen` dan memindahkan/mengadaptasi logika FAB serta pemanggilan modal QR ke sana.