enum TransactionType {
  income,
  expense,
}

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }

  String get value {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  static TransactionType fromString(String? raw) {
    if (raw == 'expense') return TransactionType.expense;
    return TransactionType.income;
  }
}
