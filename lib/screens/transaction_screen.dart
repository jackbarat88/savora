import 'package:flutter/material.dart';

import '/models/category_model.dart';
import '/models/transaction_model.dart';
import '/models/transaction_type.dart';
import '/repositories/category_repository.dart';
import '/repositories/transaction_repository.dart';
import '/utils/currency_formatter.dart';
import '/utils/date_formatter.dart';
import '/widgets/transaction_card.dart';
import '/widgets/transaction_form.dart';

class TransactionScreen extends StatefulWidget {
  final String userId;
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  const TransactionScreen({
    super.key,
    required this.userId,
    required this.transactionRepository,
    required this.categoryRepository,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<TransactionModel> _all = [];
  List<TransactionModel> _filtered = [];
  List<CategoryModel> _allCategories = [];

  TransactionType? _typeFilter;
  String? _categoryFilter;
  int? _monthFilter;
  int? _yearFilter;

  TransactionModel? _editing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txs =
        await widget.transactionRepository.getTransactionsByUser(widget.userId);
    final cats =
        await widget.categoryRepository.getAllCategories(widget.userId);
    if (!mounted) return;
    setState(() {
      _all = txs;
      _allCategories = cats;
      _loading = false;
    });
    _applyFilter();
  }

  void _applyFilter() {
    var list = _all;
    if (_typeFilter != null) {
      list = list.where((t) => t.type == _typeFilter).toList();
    }
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      list = list.where((t) => t.categoryId == _categoryFilter).toList();
    }
    if (_monthFilter != null) {
      list =
          list.where((t) => t.transactionDate.month == _monthFilter).toList();
    }
    if (_yearFilter != null) {
      list = list.where((t) => t.transactionDate.year == _yearFilter).toList();
    }
    setState(() => _filtered = list);
  }

  Future<List<CategoryModel>> _loadCategoriesForType(TransactionType type) {
    return widget.categoryRepository.getCategoriesByType(type, widget.userId);
  }

  Future<void> _saveTransaction(TransactionModel t) async {
    if (_editing == null) {
      await widget.transactionRepository.addTransaction(t);
    } else {
      await widget.transactionRepository.updateTransaction(t);
    }
  }

  void _onFormSaved() {
    setState(() => _editing = null);
    _load();
  }

  Future<void> _confirmDelete(TransactionModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Yakin ingin menghapus transaksi "${t.categoryName}" '
          'sebesar ${CurrencyFormatter.format(t.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await widget.transactionRepository.deleteTransaction(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus.')),
      );
      _load();
    }
  }

  List<int> get _availableYears {
    final years = _all.map((t) => t.transactionDate.year).toSet().toList()
      ..sort();
    if (years.isEmpty) years.add(DateTime.now().year);
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 820;

    return RefreshIndicator(
      onRefresh: _load,
      child: wide ? _buildWide() : _buildNarrow(),
    );
  }

  Widget _buildNarrow() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _filterSection(),
        const SizedBox(height: 12),
        _formCard(),
        const SizedBox(height: 12),
        _historyHeader(),
        _listOrEmpty(),
      ],
    );
  }

  Widget _buildWide() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 380,
            child: ListView(
              children: [
                _formCard(),
                const SizedBox(height: 16),
                _filterSection(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ListView(
              children: [
                _historyHeader(),
                _listOrEmpty(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE1E8E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_editing == null ? Icons.add_circle : Icons.edit,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _editing == null ? 'Tambah Transaksi' : 'Edit Transaksi',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (_editing != null)
                  TextButton(
                    onPressed: () => setState(() => _editing = null),
                    child: const Text('Batal edit'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TransactionForm(
              key: ValueKey(_editing?.id ?? 'add'),
              userId: widget.userId,
              initial: _editing,
              loadCategories: _loadCategoriesForType,
              onSave: _saveTransaction,
              onSaved: _onFormSaved,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE1E8E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TransactionType?>(
              initialValue: _typeFilter,
              decoration: const InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua')),
                DropdownMenuItem(
                    value: TransactionType.income, child: Text('Pemasukan')),
                DropdownMenuItem(
                    value: TransactionType.expense, child: Text('Pengeluaran')),
              ],
              onChanged: (v) {
                setState(() => _typeFilter = v);
                _applyFilter();
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _categoryFilter,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua')),
                ..._allCategories.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (v) {
                setState(() => _categoryFilter = v);
                _applyFilter();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _monthFilter,
                    decoration: const InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua')),
                      ...List.generate(12, (i) {
                        final m = i + 1;
                        return DropdownMenuItem(
                            value: m, child: Text(DateFormatter.monthName(m)));
                      }),
                    ],
                    onChanged: (v) {
                      setState(() => _monthFilter = v);
                      _applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _yearFilter,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua')),
                      ..._availableYears.map(
                        (y) => DropdownMenuItem(value: y, child: Text('$y')),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _yearFilter = v);
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _typeFilter = null;
                    _categoryFilter = null;
                    _monthFilter = null;
                    _yearFilter = null;
                  });
                  _applyFilter();
                },
                child: const Text('Reset filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        'Riwayat Transaksi (${_filtered.length})',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _listOrEmpty() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text('Tidak ada transaksi.'),
          ],
        ),
      );
    }

    final wide = MediaQuery.of(context).size.width >= 820;
    if (wide) {
      return _buildTable();
    }
    return Column(
      children: _filtered
          .map((t) => TransactionCard(
                transaction: t,
                onTap: () => setState(() => _editing = t),
                onDelete: () => _confirmDelete(t),
              ))
          .toList(),
    );
  }

  Widget _buildTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE1E8E5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 760),
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Tanggal')),
              DataColumn(label: Text('Tipe')),
              DataColumn(label: Text('Kategori')),
              DataColumn(label: Text('Jumlah'), numeric: true),
              DataColumn(label: Text('Catatan')),
              DataColumn(label: Text('')),
            ],
            rows: _filtered.map((t) {
              final isIncome = t.type == TransactionType.income;
              return DataRow(
                onSelectChanged: (_) => setState(() => _editing = t),
                cells: [
                  DataCell(Text(DateFormatter.formatFull(t.transactionDate))),
                  DataCell(Text(t.type.label)),
                  DataCell(Text(t.categoryName)),
                  DataCell(Text(
                    CurrencyFormatter.format(t.amount),
                    style: TextStyle(
                      color: isIncome
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  DataCell(SizedBox(
                    width: 180,
                    child: Text(
                      t.note.isEmpty ? '-' : t.note,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => setState(() => _editing = t),
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                        onPressed: () => _confirmDelete(t),
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
