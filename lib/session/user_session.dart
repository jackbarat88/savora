import '/models/user_model.dart';

class UserSession {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void set(UserModel user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }

  String? get currentUserId => _currentUser?.id;
}
