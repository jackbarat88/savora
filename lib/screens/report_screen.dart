import 'package:flutter/material.dart';

import '/models/monthly_report.dart';
import '/repositories/transaction_repository.dart';
import '/services/finance_service.dart';
import '/utils/currency_formatter.dart';
import '/utils/date_formatter.dart';
import '/widgets/summary_card.dart';

class ReportScreen extends StatefulWidget {
  final String userId;
  final TransactionRepository transactionRepository;
  final FinanceService financeService;

  const ReportScreen({
    super.key,
    required this.userId,
    required this.transactionRepository,
    required this.financeService,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late int _month;
  late int _year;
  List<int> _availableYears = [];
  MonthlyReport? _report;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _availableYears = [now.year];
    _generate();
  }

  Future<void> _generate() async {
    setState(() => _loading = true);

    final list = await widget.transactionRepository.filterTransactions(
      userId: widget.userId,
      month: _month,
      year: _year,
    );
    final all = await widget.transactionRepository.getTransactionsByUser(
      widget.userId,
    );
    final years = all.map((t) => t.transactionDate.year).toSet()
      ..add(DateTime.now().year);
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

    final report = widget.financeService.calculateMonthlyReport(
      transactions: list,
      month: _month,
      year: _year,
    );

    if (!mounted) return;
    setState(() {
      _report = report;
      _availableYears = sortedYears;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 540;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Laporan Bulanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih bulan dan tahun untuk melihat ringkasan.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE1E8E5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _month,
                        decoration: const InputDecoration(
                          labelText: 'Bulan',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(DateFormatter.monthName(i + 1)),
                          ),
                        ),
                        onChanged: (v) {
                          if (v != null) setState(() => _month = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _year,
                        decoration: const InputDecoration(
                          labelText: 'Tahun',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _availableYears
                            .map((y) =>
                                DropdownMenuItem(value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _year = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _generate,
                    icon: const Icon(Icons.assessment),
                    label: const Text('Tampilkan Laporan'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_report == null)
          const SizedBox.shrink()
        else ...[
          Center(
            child: Text(
              '${DateFormatter.monthName(_report!.month)} ${_report!.year}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          SummaryCard(
            title: 'Saldo Bulan Ini',
            value: CurrencyFormatter.format(_report!.balance),
            icon: Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Pemasukan',
                    value: CurrencyFormatter.format(_report!.totalIncome),
                    icon: Icons.arrow_downward,
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Pengeluaran',
                    value: CurrencyFormatter.format(_report!.totalExpense),
                    icon: Icons.arrow_upward,
                    isPositive: false,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SummaryCard(
                  title: 'Total Pemasukan',
                  value: CurrencyFormatter.format(_report!.totalIncome),
                  icon: Icons.arrow_downward,
                  isPositive: true,
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Total Pengeluaran',
                  value: CurrencyFormatter.format(_report!.totalExpense),
                  icon: Icons.arrow_upward,
                  isPositive: false,
                ),
              ],
            ),
          const SizedBox(height: 12),
          SummaryCard(
            title: 'Jumlah Transaksi',
            value: '${_report!.transactionCount}',
            icon: Icons.receipt_long,
            color: Colors.blueGrey,
          ),
        ],
      ],
    );
  }
}
