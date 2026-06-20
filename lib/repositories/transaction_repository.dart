import 'package:hive/hive.dart';

import '/models/transaction_model.dart';
import '/models/transaction_type.dart';
import '/services/storage_service.dart';

/// Repository untuk CRUD operasi transaksi
/// Abstraction layer antara service dan Hive database
/// Semua transaksi disimpan per-user untuk data isolation
class TransactionRepository {
  final Box _box;

  TransactionRepository() : _box = StorageService.transactions;

  /// Add transaksi baru ke database
  /// - Validasi amount harus positive
  /// - Throw ArgumentError kalau amount <= 0
  Future<void> addTransaction(TransactionModel transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Jumlah transaksi harus lebih dari 0.');
    }
    await _box.put(transaction.id, transaction.toMap());
  }

  /// Update transaksi yang sudah ada
  /// - Hanya boleh update transaksi milik user sendiri (security check)\n  /// - Validasi amount harus positive
  Future<void> updateTransaction(TransactionModel transaction) async {
    final raw = _box.get(transaction.id);
    if (raw is! Map) return;

    final saved = TransactionModel.fromMap(Map<dynamic, dynamic>.from(raw));
    // Pastikan user tidak bisa edit transaksi orang lain
    if (saved.userId != transaction.userId || transaction.amount <= 0) {
      return;
    }

    await _box.put(transaction.id, transaction.toMap());
  }

  /// Hapus transaksi by ID
  Future<void> deleteTransaction(String transactionId) async {
    await _box.delete(transactionId);
  }

  /// Get semua transaksi milik user, sorted by date (newest first)
  Future<List<TransactionModel>> getTransactionsByUser(String userId) async {
    final result = <TransactionModel>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is! Map) continue;
      final t = TransactionModel.fromMap(Map<dynamic, dynamic>.from(raw));
      if (t.userId == userId) {
        result.add(t);
      }
    }
    // Sort by date, newest first\n    result.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return result;
  }

  /// Filter transaksi dengan multiple criteria
  /// - type: Pemasukan atau Pengeluaran\n  /// - categoryId: Kategori transaksi\n  /// - month: Bulan (1-12)\n  /// - year: Tahun\n  /// \n  /// Semua parameter optional, bisa di-combine
  Future<List<TransactionModel>> filterTransactions({
    required String userId,
    TransactionType? type,
    String? categoryId,
    int? month,
    int? year,
  }) async {
    var list = await getTransactionsByUser(userId);

    // Apply filters satu-satu
    if (type != null) {
      list = list.where((t) => t.type == type).toList();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((t) => t.categoryId == categoryId).toList();
    }
    if (month != null) {
      list = list.where((t) => t.transactionDate.month == month).toList();
    }
    if (year != null) {
      list = list.where((t) => t.transactionDate.year == year).toList();
    }

    return list;
  }
}
