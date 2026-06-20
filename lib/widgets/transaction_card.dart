import 'package:flutter/material.dart';

import '/models/transaction_model.dart';
import '/models/transaction_type.dart';
import '/utils/currency_formatter.dart';
import '/utils/date_formatter.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final accent = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    final sign = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE1E8E5)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.12),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: accent,
            size: 20,
          ),
        ),
        title: Text(
          transaction.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormatter.formatFull(transaction.transactionDate),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (transaction.note.isNotEmpty)
              Text(
                transaction.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign ${CurrencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.grey.shade500,
                onPressed: onDelete,
                tooltip: 'Hapus',
              ),
          ],
        ),
      ),
    );
  }
}
