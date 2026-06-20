import 'package:hive/hive.dart';

import '/models/category_model.dart';
import '/models/transaction_type.dart';
import '/services/storage_service.dart';

class CategoryRepository {
  final Box _box;

  CategoryRepository() : _box = StorageService.categories;

  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category.toMap());
  }

  Future<List<CategoryModel>> getCategoriesByType(
    TransactionType type,
    String userId,
  ) async {
    final all = await getAllCategories(userId);
    return all.where((c) => c.type == type).toList();
  }

  Future<List<CategoryModel>> getAllCategories(String userId) async {
    final result = <CategoryModel>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is! Map) continue;
      final cat = CategoryModel.fromMap(Map<dynamic, dynamic>.from(raw));
      if (cat.userId == null || cat.userId == userId) {
        result.add(cat);
      }
    }
    result.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }

  Future<bool> isDuplicate(
    String name,
    TransactionType type,
    String userId,
  ) async {
    final normalizedName = name.trim().toLowerCase();
    final list = await getAllCategories(userId);
    for (final c in list) {
      if (c.type == type && c.name.trim().toLowerCase() == normalizedName) {
        return true;
      }
    }
    return false;
  }
}
