// lib/models/deposit_model.dart
import 'package:intl/intl.dart'; // Untuk parsing dan formatting tanggal
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class Deposit {
  final int id;
  final String
  detectedType; // Tipe item yang terdeteksi (misal: "PET_MINERAL_EMPTY")
  final int pointsAwarded;
  final DateTime createdAt; // Waktu deposit dibuat

  Deposit({
    required this.id,
    required this.detectedType,
    required this.pointsAwarded,
    required this.createdAt,
  });

  // Factory constructor untuk membuat instance Deposit dari JSON Map
  factory Deposit.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      // Coba parse dengan format ISO 8601 yang umum dari Laravel
      parsedDate = DateTime.parse(json['created_at'] as String);
    } catch (e) {
      // Fallback jika format berbeda atau parsing gagal
      debugPrint('Error parsing date: ${json['created_at']}. Error: $e');
      parsedDate = DateTime.now(); // Default ke waktu sekarang jika gagal
    }

    return Deposit(
      id: json['id'] as int? ?? 0, // Beri default jika null
      detectedType:
          json['detected_type'] as String? ?? 'Unknown', // Beri default
      pointsAwarded: json['points_awarded'] as int? ?? 0, // Beri default
      createdAt: parsedDate,
    );
  }

  // Helper untuk format tanggal yang mudah dibaca
  String get formattedDate {
    // Contoh format: 12 Mei 2025, 10:30
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(createdAt);
  }

  // Helper untuk format tipe item yang lebih ramah
  String get friendlyItemType {
    // Anda bisa kembangkan ini sesuai label dari Gemini/Backend
    switch (detectedType) {
      case 'PET_MINERAL_EMPTY':
        return 'Botol PET Bening';
      case 'PET_COLORED_EMPTY':
        return 'Botol PET Berwarna';
      case 'ALUMINUM_CAN_EMPTY':
        return 'Kaleng Aluminium';
      case 'PET_SODA_EMPTY':
        return 'Botol Soda PET';
      case 'REJECTED_UNKNOWN_TYPE':
        return 'Ditolak (Tidak Dikenali)';
      case 'REJECTED_HAS_CONTENT_OR_TRASH':
        return 'Ditolak (Ada Isi/Sampah)';
      case 'REJECTED_UNIDENTIFIED': // Tambahkan ini jika ada di backend
        return 'Ditolak (Tidak Teridentifikasi)';
      // Tambahkan case lain sesuai kebutuhan
      default:
        return detectedType; // Tampilkan apa adanya jika tidak ada mapping
    }
  }
}
