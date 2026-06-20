import '/models/monthly_report.dart';
import '/models/transaction_model.dart';
import '/models/transaction_type.dart';

class FinanceService {
  double calculateTotalIncome(List<TransactionModel> transactions) {
    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        total += t.amount;
      }
    }
    return total;
  }

  double calculateTotalExpense(List<TransactionModel> transactions) {
    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        total += t.amount;
      }
    }
    return total;
  }

  double calculateBalance(List<TransactionModel> transactions) {
    return calculateTotalIncome(transactions) -
        calculateTotalExpense(transactions);
  }

  MonthlyReport calculateMonthlyReport({
    required List<TransactionModel> transactions,
    required int month,
    required int year,
  }) {
    if (transactions.isEmpty) {
      return MonthlyReport.empty(month, year);
    }
    return MonthlyReport.fromTransactions(
      month: month,
      year: year,
      transactions: transactions,
    );
  }
}
