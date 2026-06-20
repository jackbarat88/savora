import 'package:flutter/material.dart';

import '/models/category_model.dart';
import '/models/transaction_model.dart';
import '/models/transaction_type.dart';
import 'category_dropdown.dart';

class TransactionForm extends StatefulWidget {
  final String userId;
  final TransactionModel? initial;

  final Future<List<CategoryModel>> Function(TransactionType type)
      loadCategories;

  final Future<void> Function(TransactionModel transaction) onSave;

  final VoidCallback? onSaved;

  const TransactionForm({
    super.key,
    required this.userId,
    required this.loadCategories,
    required this.onSave,
    this.initial,
    this.onSaved,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late TransactionType _type;
  DateTime _date = DateTime.now();
  String? _categoryId;
  List<CategoryModel> _categories = [];
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _type = init.type;
      _date = init.transactionDate;
      _categoryId = init.categoryId;
      _amountCtrl.text = init.amount == init.amount.toInt()
          ? init.amount.toInt().toString()
          : init.amount.toStringAsFixed(2);
      _noteCtrl.text = init.note;
    } else {
      _type = TransactionType.expense;
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    final list = await widget.loadCategories(_type);
    if (!mounted) return;
    setState(() {
      _categories = list;
      _loading = false;
      if (_categoryId != null && !_categories.any((c) => c.id == _categoryId)) {
        _categoryId = null;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _onTypeChanged(TransactionType? type) {
    if (type == null || type == _type) return;
    setState(() {
      _type = type;
      _categoryId = null;
    });
    _loadCategories();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah transaksi harus lebih dari 0.')),
      );
      return;
    }

    setState(() => _saving = true);

    final selected = _categories.firstWhere(
      (c) => c.id == _categoryId,
      orElse: () => _categories.first,
    );

    TransactionModel transaction;
    if (_isEdit) {
      transaction = widget.initial!.copyWith(
        categoryId: selected.id,
        categoryName: selected.name,
        type: _type,
        amount: amount,
        note: _noteCtrl.text.trim(),
        transactionDate: _date,
      );
    } else {
      transaction = TransactionModel.create(
        userId: widget.userId,
        categoryId: selected.id,
        categoryName: selected.name,
        type: _type,
        amount: amount,
        note: _noteCtrl.text.trim(),
        transactionDate: _date,
      );
    }

    await widget.onSave(transaction);

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit
            ? 'Transaksi berhasil diperbarui.'
            : 'Transaksi berhasil ditambahkan.'),
      ),
    );

    widget.onSaved?.call();

    if (!_isEdit) {
      _formKey.currentState?.reset();
      _amountCtrl.clear();
      _noteCtrl.clear();
      setState(() {
        _categoryId = null;
        _date = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Pengeluaran'),
                icon: Icon(Icons.remove_circle_outline),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Pemasukan'),
                icon: Icon(Icons.add_circle_outline),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (set) => _onTypeChanged(set.first),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                '${_date.day.toString().padLeft(2, '0')}/'
                '${_date.month.toString().padLeft(2, '0')}/'
                '${_date.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            CategoryDropdown(
              categories: _categories,
              type: _type,
              selectedId: _categoryId,
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Jumlah (Rp)',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Data tidak boleh kosong.';
              }
              final amount = double.tryParse(value.trim().replaceAll(',', '.'));
              if (amount == null) {
                return 'Jumlah transaksi harus berupa angka.';
              }
              if (amount <= 0) {
                return 'Jumlah transaksi harus lebih dari 0.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_isEdit ? Icons.save : Icons.add),
                  label: Text(_isEdit ? 'Perbarui' : 'Tambah'),
                ),
              ),
              if (!_isEdit) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                    _amountCtrl.clear();
                    _noteCtrl.clear();
                    setState(() {
                      _categoryId = null;
                      _date = DateTime.now();
                    });
                  },
                  child: const Text('Bersihkan'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
