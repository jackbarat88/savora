import 'package:hive_flutter/hive_flutter.dart';

import '/models/category_model.dart';
import '/models/transaction_type.dart';
import '/models/user_model.dart';
import '/utils/password_util.dart';

class StorageService {
  static const String usersBox = 'usersBox';
  static const String categoriesBox = 'categoriesBox';
  static const String transactionsBox = 'transactionsBox';

  static const String _defaultDataKey = 'defaultDataSeeded';

  static Box? _users;
  static Box? _categories;
  static Box? _transactions;

  static Box get users => _users!;
  static Box get categories => _categories!;
  static Box get transactions => _transactions!;

  static Future<void> init() async {
    await Hive.initFlutter();
    await openBoxes();
    await insertDefaultData();
  }

  static Future<void> openBoxes() async {
    _users = await Hive.openBox(usersBox);
    _categories = await Hive.openBox(categoriesBox);
    _transactions = await Hive.openBox(transactionsBox);
  }

  static bool get _alreadySeeded {
    return _users?.get(_defaultDataKey, defaultValue: false) == true;
  }

  static Future<void> insertDefaultData() async {
    if (!_users!.containsKey('admin')) {
      final admin = UserModel.create(
        fullName: 'Demo User',
        username: 'admin',
        passwordHash: PasswordUtil.hash('admin123'),
      );
      await _users!.put(admin.username, admin.toMap());
    }

    await _insertDefaultCategoryNames(
      ['Uang Saku', 'Beasiswa', 'Kerja Sampingan', 'Lainnya'],
      TransactionType.income,
    );

    await _insertDefaultCategoryNames(
      ['Makan', 'Transportasi', 'Kuliah', 'Hiburan', 'Belanja', 'Lainnya'],
      TransactionType.expense,
    );

    if (!_alreadySeeded) {
      await _users!.put(_defaultDataKey, true);
    }
  }

  static Future<void> _insertDefaultCategoryNames(
    List<String> names,
    TransactionType type,
  ) async {
    final existing = _categories!.values
        .whereType<Map>()
        .map((raw) => CategoryModel.fromMap(Map<dynamic, dynamic>.from(raw)))
        .where((cat) => cat.userId == null && cat.type == type)
        .map((cat) => cat.name.trim().toLowerCase())
        .toSet();

    for (final name in names) {
      if (existing.contains(name.toLowerCase())) continue;
      final cat = CategoryModel.create(
        userId: null,
        name: name,
        type: type,
      );
      await _categories!.put(cat.id, cat.toMap());
      existing.add(name.toLowerCase());
    }
  }
}
