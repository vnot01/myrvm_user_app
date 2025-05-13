// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
// Import model dan service akan ditambahkan nanti
import '../models/deposit_model.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AuthService _authService = AuthService(); // Instance AuthService
  bool _isLoading = true; // Awalnya loading
  String? _errorMessage;
  List<Deposit> _deposits = []; // List untuk menyimpan data
  int _currentPage = 1;
  int? _lastPage;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk fetch data nanti di sini
    _fetchHistory(isRefresh: true);
    _scrollController.addListener(_scrollListener); // Tambahkan listener
  }

  Future<void> _fetchHistory({bool isRefresh = false, int page = 1}) async {
    // Jika bukan refresh, set loading awal
    if (!isRefresh) {
      if (mounted) {
        setState(() {
          // Tampilkan loading utama saat refresh
          _isLoading = true;
          // Reset error message
          _errorMessage = null;
          _currentPage = 1;
          _deposits = [];
          // Reset last page juga
          _lastPage = null;
        });
      }
    } else if (page > 1) {
      // Jika memuat halaman berikutnya, set loading more
      if (mounted) setState(() => _isLoadingMore = true);
    } else {
      // Jika memuat halaman pertama (bukan refresh), set loading awal
      if (mounted) setState(() => _isLoading = true);
    }

    debugPrint(
      "HistoryScreen: Fetching history page $page (isRefresh: $isRefresh)",
    );
    final result = await _authService.getDepositHistory(
      page: 1,
    ); // Ambil halaman pertama

    // Bungkus pemanggilan API dengan try-catch
    try {
      final result = await _authService.getDepositHistory(page: page);
      if (mounted) {
        // Pastikan widget masih ada di tree
        if (result['success']) {
          final List<Deposit> newDeposits = result['data'] as List<Deposit>;
          final meta = result['meta'] as Map<String, dynamic>?;
          setState(() {
            if (isRefresh || page == 1) {
              _deposits = newDeposits; // Ganti data jika refresh atau halaman 1
            } else {
              _deposits.addAll(
                newDeposits,
              ); // Tambahkan data jika halaman berikutnya
            }
            _currentPage = meta?['current_page'] as int? ?? _currentPage;
            _lastPage = meta?['last_page'] as int?;
            _isLoading = false; // Selesai loading awal
            _isLoadingMore = false; // Selesai loading more
            _errorMessage = null; // Hapus error jika sukses
          });
          debugPrint(
            "HistoryScreen: Fetch success page $page. Items: ${newDeposits.length}. Total: ${_deposits.length}. LastPage: $_lastPage",
          );
        } else {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            // Jangan reset deposit jika error saat loading more
            if (page == 1 || isRefresh) {
              _deposits = []; // Kosongkan hanya jika error di load awal/refresh
              _errorMessage =
                  result['message'] as String? ?? 'Gagal memuat riwayat.';
            } else {
              // Jika error saat load more, tampilkan SnackBar mungkin?
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['message'] as String? ??
                        'Gagal memuat data selanjutnya.',
                  ),
                ),
              );
            }
          });
          debugPrint(
            "HistoryScreen: Fetch failed page $page. Message: ${result['message']}",
          );
        }
      }
    } catch (e) {
      debugPrint("HistoryScreen: Exception during fetchHistory page $page: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          if (page == 1 || isRefresh) {
            _deposits = [];
            _errorMessage = "Terjadi kesalahan: ${e.toString()}";
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // Menghapus listener
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Cek jika sudah dekat bawah DAN tidak sedang loading DAN masih ada halaman
    // Cek jika sudah dekat bawah DAN tidak sedang loading more DAN masih ada halaman berikutnya
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _lastPage != null &&
        _currentPage < _lastPage!) {
      debugPrint("HistoryScreen: Scroll near bottom, triggering fetch more.");
      _fetchHistory(
        page: _currentPage + 1,
      ); // Panggil fetch untuk halaman berikutnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Deposit'),
        automaticallyImplyLeading: false,
      ),
      // Tambahkan RefreshIndicator
      body: RefreshIndicator(
        // Panggil fetch lagi saat di-refresh
        onRefresh: () => _fetchHistory(isRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      // Tampilkan error dengan tombol coba lagi
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                // Panggil fetch halaman pertama saat coba lagi
                onPressed: () => _fetchHistory(isRefresh: true),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan pesan kosong hanya jika tidak loading DAN tidak error DAN _deposits kosong
    if (!_isLoading && _errorMessage == null && _deposits.isEmpty) {
      // Tampilan jika data kosong dengan ikon
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat deposit.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Tampilkan ListView
    return ListView.builder(
      controller: _scrollController, // <-- Tambahkan controller
      // +1 untuk item loading indicator di bawah jika _isLoadingMore true
      itemCount: _deposits.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Jika index adalah item terakhir DAN sedang loading more
        if (index == _deposits.length && _isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Jika index di luar batas (seharusnya tidak terjadi, tapi sebagai pengaman)
        if (index >= _deposits.length) {
          return const SizedBox.shrink(); // Return widget kosong
        }

        // Tampilkan item deposit seperti biasa
        final deposit = _deposits[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          elevation: 2.0,
          child: ListTile(
            leading: Icon(
              deposit.pointsAwarded > 0
                  ? Icons.check_circle_outline
                  : Icons.highlight_off,
              color: deposit.pointsAwarded > 0 ? Colors.green : Colors.red,
              size: 30,
            ),
            title: Text(
              deposit.friendlyItemType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(deposit.formattedDate),
            trailing: Text(
              '${deposit.pointsAwarded > 0 ? '+' : ''}${deposit.pointsAwarded} Poin',
              style: TextStyle(
                color:
                    deposit.pointsAwarded > 0 ? Colors.blueAccent : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }
}
