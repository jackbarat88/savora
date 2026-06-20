import 'package:hive/hive.dart';

import '/models/user_model.dart';
import '/services/storage_service.dart';

class UserRepository {
  final Box _box;

  UserRepository() : _box = StorageService.users;

  Future<void> addUser(UserModel user) async {
    await _box.put(_normalize(user.username), user.toMap());
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final raw = _box.get(_normalize(username));
    if (raw == null) return null;
    return UserModel.fromMap(Map<dynamic, dynamic>.from(raw));
  }

  Future<bool> isUsernameTaken(String username) async {
    return _box.containsKey(_normalize(username));
  }

  Future<List<UserModel>> getAllUsers() async {
    final result = <UserModel>[];
    for (final key in _box.keys) {
      if (key == 'defaultDataSeeded') continue;
      final raw = _box.get(key);
      if (raw is Map) {
        result.add(UserModel.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }
    return result;
  }

  String _normalize(String username) => username.trim().toLowerCase();
}
