Saya ulangin saja satu satu seperti nya anda belum memahami maksud saya:
1. HomeScreen Tampilan Awal:
Memiliki BottomAppBar dengan item Home (Contoh suatu saat akan di ganti), Statistic (Contoh suatu saat akan di ganti), (ruang kosong untuk FAB), History (Contoh suatu saat akan di ganti), Profile (Contoh suatu saat akan di ganti).

2. FloatingActionButton.extended (dengan ikon QR dan teks "QR" di bawah icon QR) yang berbentuk lingkaran akan ditempatkan di tengah bawah layar (`FloatingActionButtonLocation.centerDocked`), terintegrasi dengan `BottomAppBar` yang memiliki lekukan (`CircularNotchedRectangle`) namun lingkaran FAB tersebut ukurannya seimbang dengan lekukan `BottomAppBar` (contoh akan saya lampirkan). `BottomAppBar` ini akan berisi item navigasi utama lainnya (Home, Statistik, Riwayat, Profil). Jika pengguna menekan FAB QR lagi, selalu generate token BARU dan Menjadi Trigger dari Modal Buttom Sheet membuka. dan menjalankan Polling ke /api/user/check-rvm-scan-status (setiap 5-10 detik).

3. Area QR Code berbentuk Modal Bottom Sheet yang berisi Judul "Kode QR Deposit Anda" atau "QR Anda". Gambar `QrImageView yang besar dan jelas`. Di bawah `QR Code` terdapat Teks instruksi `"Arahkan kode ini ke kamera mesin RVM.".` Di bawah Teks Intruksi ada `tombol` memiliki `ikon QR dengan teks "Generate Ulang Kode"`. Saat QR Code tampil, area ini `tombol` mengalami perubahan `ikon` menjadi `timer (jam) dan teks "04:59"`. `Teks "04:59"` adalah sebuah timer yang menghitung mundur. Timer internal `5 menit`. Timer terus berjalan mundur dan Status `Tombol` ini `Disabled (tidak bisa di klik)`.  Namun, ketika Timer ini habis atau `00:00` (expired token) maka QR Code menampilkan Placeholder (ikon QR abu-abu dan teks `"Tekan 'Generate Ulang Kode' untuk Generate Ulang QR Code (Kode Deposit)"`) serta `tombol` ini berganti status menjadi `enabled` (bisa di klik).

4. Cara menutup Modal Bottom Sheet yaitu Pengguna bisa menutup modal dengan tombol yang memiliki `icon X (tanpa tulisan)` di pojok kanan atas modal atau gestur swipe-down. Ketika di tutup maka timer berhenti, polling berhenti, pencahayaan kembali ke tingkat semula (jika sebelumnya diubah). Update status User, seperti History deposit, jumlah poin reward, dll yang berhubungan dengan status Users. setiap ada perubahan dari text, gambar atau assets tolong gunakan shimmer loading effect.

5. Kontrol Pencahayaan Layar dengan Izin Pengguna, setelah menekan tombol FAB dan atau menekan tombol "Generate Ulang Kode". Menyimpan Tingkat pencahayaan penggunaan saat ini, kemudian ketika QR Code muncul maka pencahayaan monitor atau LCD atau HP menjadi maksimum. Setelah QR tidak lagi ditampilkan (timer habis, scan sukses, atau pengguna navigasi ke Screen lain atau ke menu lain, atau user menutup Modal Bottom Sheet), kembalikan kecerahan layar ke tingkat semula (jika sebelumnya diubah). Transparansi & Kontrol Pengguna Memberi tahu pengguna mengapa perubahan pengaturan sistem diperlukan dan memberi mereka pilihan

6. Polling ke /api/user/check-rvm-scan-status (setiap 5-10 detik). di gunakan untuk mengirimkan notifikasi SUkses Scan. Setelah QR ditampilkan di Aplikasi User, Aplikasi User mulai polling ke /api/user/check-rvm-scan-status?token=<rvm_login_token> setiap beberapa detik (misalnya, 5-10 detik) selama durasi token (5 menit) atau sampai status "sukses" diterima.

Jangan di Terapkan terlebih dahulu. tolong di analisa ulang. saya juga mengirimkan Screenshot aplikasi tampilan Home kita. O iya, Tambahkan kan ucapan Selamat Datang beserta nama User nya. untuk menghargai User dan menghormati User di Halaman HOme depan paling awal.

Ingatkan saya ini merupakan revisi ke berapa?

saya mengunggah Gambar lagi sebagai refrensi.
BottomAppBar dengan FAB yang bulat dan lekukan.
dan 
Modal Bottom Sheet dengan yang berisi dengan elemen icon swipe down / up, Header Text, QrImageView, Footer Text (yang nantinya akan menjadi Teks instruksi `"Arahkan kode ini ke kamera mesin RVM.".`), terakhir ada button (yang nantinya akan menjadi button yang memiliki `ikon QR dengan teks "Generate Ulang Kode"`).