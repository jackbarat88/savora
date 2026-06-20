import 'package:flutter_test/flutter_test.dart';

import 'package:savora/models/transaction_model.dart';
import 'package:savora/models/transaction_type.dart';
import 'package:savora/services/finance_service.dart';
import 'package:savora/utils/currency_formatter.dart';
import 'package:savora/utils/password_util.dart';

TransactionModel _tx(TransactionType type, double amount) {
  return TransactionModel(
    id: 'id-$type-$amount',
    userId: 'user-1',
    categoryId: 'cat-1',
    categoryName: 'Test',
    type: type,
    amount: amount,
    note: '',
    transactionDate: DateTime(2024, 4, 5),
    createdAt: DateTime(2024, 4, 5),
    updatedAt: DateTime(2024, 4, 5),
  );
}

void main() {
  group('PasswordUtil', () {
    test('hash sama untuk input yang sama', () {
      expect(PasswordUtil.hash('admin123'), PasswordUtil.hash('admin123'));
    });

    test('verify benar untuk password cocok', () {
      final hash = PasswordUtil.hash('rahasia');
      expect(PasswordUtil.verify('rahasia', hash), isTrue);
      expect(PasswordUtil.verify('salah', hash), isFalse);
    });
  });

  group('CurrencyFormatter', () {
    test('format angka ke Rupiah', () {
      expect(CurrencyFormatter.format(50000), contains('Rp'));
      expect(CurrencyFormatter.format(0), contains('0'));
    });
  });

  group('FinanceService', () {
    final service = FinanceService();
    final transactions = [
      _tx(TransactionType.income, 100000),
      _tx(TransactionType.income, 50000),
      _tx(TransactionType.expense, 30000),
    ];

    test('total pemasukan terhitung', () {
      expect(service.calculateTotalIncome(transactions), 150000);
    });

    test('total pengeluaran terhitung', () {
      expect(service.calculateTotalExpense(transactions), 30000);
    });

    test('saldo = pemasukan - pengeluaran', () {
      expect(service.calculateBalance(transactions), 120000);
    });

    test('laporan bulanan kosong saat tidak ada transaksi', () {
      final report = service.calculateMonthlyReport(
        transactions: [],
        month: 4,
        year: 2024,
      );
      expect(report.transactionCount, 0);
      expect(report.balance, 0);
    });
  });
}
