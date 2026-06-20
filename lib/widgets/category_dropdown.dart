import 'package:flutter/material.dart';

import '/models/category_model.dart';
import '/models/transaction_type.dart';

class CategoryDropdown extends StatelessWidget {
  final List<CategoryModel> categories;
  final TransactionType type;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.type,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Kategori',
          border: const OutlineInputBorder(),
          helperText: 'Tambahkan kategori ${type.label.toLowerCase()} dulu.',
        ),
        validator: (_) => 'Silakan pilih kategori.',
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(),
      ),
      items: categories.map((c) {
        return DropdownMenuItem<String>(
          value: c.id,
          child: Text(c.name),
        );
      }).toList(),
      hint: const Text('Pilih kategori'),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Silakan pilih kategori.';
        }
        return null;
      },
    );
  }
}
