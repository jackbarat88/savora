import 'package:hive/hive.dart';

import '/models/transaction_model.dart';
import '/models/transaction_type.dart';
import '/services/storage_service.dart';

class TransactionRepository {
  final Box _box;

  TransactionRepository() : _box = StorageService.transactions;

  Future<void> addTransaction(TransactionModel transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Jumlah transaksi harus lebih dari 0.');
    }
    await _box.put(transaction.id, transaction.toMap());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final raw = _box.get(transaction.id);
    if (raw is! Map) return;

    final saved = TransactionModel.fromMap(Map<dynamic, dynamic>.from(raw));
    if (saved.userId != transaction.userId || transaction.amount <= 0) {
      return;
    }

    await _box.put(transaction.id, transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _box.delete(transactionId);
  }

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
    result.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return result;
  }

  Future<List<TransactionModel>> filterTransactions({
    required String userId,
    TransactionType? type,
    String? categoryId,
    int? month,
    int? year,
  }) async {
    var list = await getTransactionsByUser(userId);

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
