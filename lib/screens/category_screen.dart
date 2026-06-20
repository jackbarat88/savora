import 'package:flutter/material.dart';

import '/models/category_model.dart';
import '/models/transaction_type.dart';
import '/repositories/category_repository.dart';

class CategoryScreen extends StatefulWidget {
  final String userId;
  final CategoryRepository categoryRepository;

  const CategoryScreen({
    super.key,
    required this.userId,
    required this.categoryRepository,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;

  List<CategoryModel> _incomeCats = [];
  List<CategoryModel> _expenseCats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final income = await widget.categoryRepository
        .getCategoriesByType(TransactionType.income, widget.userId);
    final expense = await widget.categoryRepository
        .getCategoriesByType(TransactionType.expense, widget.userId);
    if (!mounted) return;
    setState(() {
      _incomeCats = income;
      _expenseCats = expense;
      _loading = false;
    });
  }

  Future<void> _addCategory() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tidak boleh kosong.')),
      );
      return;
    }

    final dup =
        await widget.categoryRepository.isDuplicate(name, _type, widget.userId);
    if (!mounted) return;
    if (dup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kategori dengan nama dan tipe itu sudah ada.')),
      );
      return;
    }

    final cat = CategoryModel.create(
      userId: widget.userId,
      name: name,
      type: _type,
    );
    await widget.categoryRepository.addCategory(cat);

    _nameCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori berhasil ditambahkan.')),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
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
                const Text('Tambah Kategori',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Pengeluaran')),
                    ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Pemasukan')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          _categoryGroup(
              'Kategori Pemasukan', _incomeCats, Colors.green.shade700),
          const SizedBox(height: 16),
          _categoryGroup(
              'Kategori Pengeluaran', _expenseCats, Colors.red.shade700),
        ],
      ],
    );
  }

  Widget _categoryGroup(String title, List<CategoryModel> cats, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.map((c) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  c.isDefault ? Icons.public : Icons.person,
                  size: 16,
                  color: color,
                ),
              ),
              label: Text(c.name),
              backgroundColor: color.withValues(alpha: 0.06),
              side: BorderSide(color: color.withValues(alpha: 0.2)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
