import 'package:flutter/material.dart';

import '/models/transaction_model.dart';
import '/repositories/transaction_repository.dart';
import '/services/finance_service.dart';
import '/utils/currency_formatter.dart';
import '/widgets/summary_card.dart';
import '/widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final String fullName;
  final TransactionRepository transactionRepository;
  final FinanceService financeService;
  final VoidCallback? onTransactionTap;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.transactionRepository,
    required this.financeService,
    this.onTransactionTap,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await widget.transactionRepository.getTransactionsByUser(widget.userId);
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  Future<void> refresh() => _load();

  @override
  Widget build(BuildContext context) {
    final income = widget.financeService.calculateTotalIncome(_transactions);
    final expense = widget.financeService.calculateTotalExpense(_transactions);
    final balance = widget.financeService.calculateBalance(_transactions);
    final latest = _transactions.take(5).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _DashboardHeader(
            fullName: widget.fullName,
            balance: CurrencyFormatter.format(balance),
            transactionCount: _transactions.length,
          ),
          const SizedBox(height: 16),
          SummaryCard(
            title: 'Saldo Saat Ini',
            value: CurrencyFormatter.format(balance),
            icon: Icons.savings_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          ResponsiveTwoCol(
            left: SummaryCard(
              title: 'Total Pemasukan',
              value: CurrencyFormatter.format(income),
              icon: Icons.arrow_downward,
              isPositive: true,
            ),
            right: SummaryCard(
              title: 'Total Pengeluaran',
              value: CurrencyFormatter.format(expense),
              icon: Icons.arrow_upward,
              isPositive: false,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE1E8E5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.onTransactionTap != null)
                      TextButton.icon(
                        onPressed: widget.onTransactionTap,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Lihat semua'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (latest.isEmpty)
                  _emptyState()
                else
                  ...latest.map((t) => TransactionCard(
                        transaction: t,
                        onTap: () => widget.onTransactionTap?.call(),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Belum ada transaksi.'),
          const SizedBox(height: 4),
          Text(
            'Mulai catat pemasukan & pengeluaranmu.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String fullName;
  final String balance;
  final int transactionCount;

  const _DashboardHeader({
    required this.fullName,
    required this.balance,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF102E29),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E4A43)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 560;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $fullName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ringkasan keuanganmu hari ini.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.4,
                ),
              ),
            ],
          );
          final balanceBox = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment:
                  wide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  balance,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFBFE6D7),
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$transactionCount transaksi',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                ),
              ],
            ),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 16), balanceBox],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 18),
              balanceBox,
            ],
          );
        },
      ),
    );
  }
}

class ResponsiveTwoCol extends StatelessWidget {
  final Widget left;
  final Widget right;

  const ResponsiveTwoCol({
    super.key,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 540;
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      );
    }
    return Column(
      children: [
        left,
        const SizedBox(height: 12),
        right,
      ],
    );
  }
}
