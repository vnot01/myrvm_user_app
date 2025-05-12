Verifikasi Tampilan:
Apakah BottomAppBar sekarang memiliki lekukan dan FAB "QR" (ikon di atas teks) berada di tengahnya dengan pas? Anda mungkin perlu sedikit menyesuaikan notchMargin di BottomAppBar dan width dari SizedBox di Row BottomAppBar untuk mendapatkan alignment yang sempurna.
Apakah item-item menu lain (Home, Statistik, Riwayat, Profil) terlihat baik dengan ikon dan label di bawahnya?
Apakah Anda bisa berpindah antar tab (layar konten akan berubah sesuai dengan HomeScreen, StatisticScreen, dll.)?
Apakah menekan FAB "QR" masih mencetak pesan di konsol?


children: <Widget>[
            _buildNavItem(
              Icons.home_max_outlined,
              "Home",
              0,
              isSelected: _currentIndex == 0,
            ),
            _buildNavItem(
              Icons.bar_chart_sharp,
              "Statistik",
              1,
              isSelected: _currentIndex == 1,
            ),
            const SizedBox(
              width: 48,
            ), // Memberi ruang kosong untuk FAB di tengah
            _buildNavItem(
              Icons.history_toggle_off,
              "Riwayat",
              2,
              isSelected: _currentIndex == 2,
            ),
            _buildNavItem(
              Icons.person_pin,
              "Profil",
              3,
              isSelected: _currentIndex == 3,
            ),
          ],