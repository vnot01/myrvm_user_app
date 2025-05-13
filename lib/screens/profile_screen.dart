// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  // Tambahkan key di konstruktor
  const ProfileScreen({Key? key}) : super(key: key);

  // @override
  // State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  // Kita tidak lagi menyimpan _userData dan _isLoading sebagai state di sini,
  // FutureBuilder akan menanganinya.

  // Future untuk data profil
  late Future<Map<String, dynamic>?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    // Panggil _fetchUserProfile untuk mendapatkan Future-nya
    _userProfileFuture = _fetchUserProfile();
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    debugPrint("ProfileScreen: Memulai _fetchUserProfile...");
    try {
      final userProfile = await _authService.getUserProfile();
      if (userProfile != null) {
        debugPrint("ProfileScreen: Data profil berhasil diambil: $userProfile");
        return userProfile;
      } else {
        debugPrint(
          "ProfileScreen: Gagal mengambil data profil atau token tidak valid.",
        );
        // Jika token tidak valid, _authService.getUserProfile() sudah menghapus token lokal
        // Kita perlu navigasi ke login jika itu terjadi
        if (mounted) {
          _forceLogout("Sesi Anda telah berakhir. Silakan login kembali.");
        }
        return null;
      }
    } catch (e) {
      debugPrint("ProfileScreen: Exception saat _fetchUserProfile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error mengambil profil: ${e.toString()}")),
        );
      }
      return null; // Kembalikan null jika ada error
    }
  }

  // Metode publik untuk memicu refresh dari luar (misalnya dari MainShellScreen)
  void refreshProfile() {
    debugPrint("ProfileScreen: refreshProfile() dipanggil dari luar.");
    if (mounted) {
      setState(() {
        // Panggil lagi untuk mendapatkan Future baru
        _userProfileFuture = _fetchUserProfile();
      });
    }
  }

  Future<void> _forceLogout(String message) async {
    // Tidak perlu panggil _authService.logout() lagi,
    // jika getUserProfile sudah handle await _authService.logout();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _logout() async {
    // ... (Logika dialog konfirmasi logout sama seperti sebelumnya) ...
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      // User harus memilih salah
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Konteks untuk dialog
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false); // Tutup dialog dan kembalikan false
              },
            ),
            TextButton(
              child: const Text('Ya, Logout'),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true); // Tutup dialog dan kembalikan true
              },
            ),
          ],
        );
      },
    ); // Akhir dari showDialog

    if (confirmLogout == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("ProfileScreen: build() dipanggil.");
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: RefreshIndicator(
        onRefresh: () async {
          // Saat pull-to-refresh, panggil lagi _fetchUserProfile dan
          // update FutureBuilder
          setState(() {
            _userProfileFuture = _fetchUserProfile();
          });
        },
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _userProfileFuture, // Future yang akan diobservasi
          builder: (context, snapshot) {
            // Snapshot berisi status dari
            // Future: connectionState, data, error
            debugPrint(
              "ProfileScreen FutureBuilder: ConnectionState: ${snapshot.connectionState}",
            );
            if (snapshot.connectionState == ConnectionState.waiting) {
              debugPrint("ProfileScreen FutureBuilder: Menunggu data...");
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint(
                "ProfileScreen FutureBuilder: Error - ${snapshot.error}",
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Error memuat profil: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // snapshot.data adalah Map {'status': 'success', 'user': {...}}
              // Kita perlu mengambil objek 'user' dari dalamnya.
              final Map<String, dynamic>? userObject =
                  snapshot.data!['user'] as Map<String, dynamic>?;

              // Data berhasil diambil
              if (userObject != null) {
                // Pastikan objek user ada
                debugPrint(
                  "ProfileScreen FutureBuilder: Data userObject diterima - $userObject",
                );
                return ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          userObject['avatar'] != null
                              ? NetworkImage(userObject['avatar'])
                              : null,
                      child:
                          userObject['avatar'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileDetail('Nama', userObject['name']),
                    _buildProfileDetail('Email', userObject['email']),
                    _buildProfileDetail(
                      'Poin',
                      userObject['points']?.toString() ?? '0',
                    ),
                    _buildProfileDetail('Role', userObject['role']),
                    _buildProfileDetail(
                      'No. Telepon',
                      userObject['phone_number'],
                    ),
                    _buildProfileDetail(
                      'Kewarganegaraan',
                      userObject['citizenship'],
                    ),
                    _buildProfileDetail(
                      'Tipe Identitas',
                      userObject['identity_type'],
                    ),
                    _buildProfileDetail(
                      'No. Identitas',
                      userObject['identity_number'],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                );
              } else {
                // Jika snapshot.data ada tapi tidak ada key 'user' atau 'user' bukan Map
                debugPrint(
                  "ProfileScreen FutureBuilder: Struktur data user tidak sesuai di snapshot.",
                );
                return const Center(
                  child: Text('Format data profil tidak valid.'),
                );
              }
            } else {
              // Data null atau tidak ada data (setelah Future selesai tanpa error tapi data null)
              debugPrint(
                "ProfileScreen FutureBuilder: Tidak ada data profil atau data null.",
              );
              return const Center(
                child: Text(
                  'Tidak dapat memuat data profil. Silakan coba lagi.',
                  textAlign: TextAlign.center,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
