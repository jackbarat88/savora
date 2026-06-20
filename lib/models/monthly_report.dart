import '/models/transaction_model.dart';
import '/models/transaction_type.dart';

class MonthlyReport {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  MonthlyReport({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  double get balance => totalIncome - totalExpense;

  bool get isEmpty => transactionCount == 0;

  factory MonthlyReport.empty(int month, int year) {
    return MonthlyReport(
      month: month,
      year: year,
      totalIncome: 0,
      totalExpense: 0,
      transactionCount: 0,
    );
  }

  factory MonthlyReport.fromTransactions({
    required int month,
    required int year,
    required List<TransactionModel> transactions,
  }) {
    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return MonthlyReport(
      month: month,
      year: year,
      totalIncome: income,
      totalExpense: expense,
      transactionCount: transactions.length,
    );
  }
}
