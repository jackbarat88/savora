import '/models/user_model.dart';
import '/repositories/user_repository.dart';
import '/session/user_session.dart';
import '/utils/password_util.dart';

class AuthService {
  final UserRepository _userRepository;
  final UserSession _session;

  AuthService(this._userRepository, this._session);

  Future<bool> register({
    required String fullName,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final cleanUsername = username.trim().toLowerCase();

    if (fullName.trim().isEmpty ||
        cleanUsername.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return false;
    }

    if (password != confirmPassword) {
      return false;
    }

    if (await _userRepository.isUsernameTaken(cleanUsername)) {
      return false;
    }

    final user = UserModel.create(
      fullName: fullName.trim(),
      username: cleanUsername,
      passwordHash: PasswordUtil.hash(password),
    );
    await _userRepository.addUser(user);
    return true;
  }

  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    if (cleanUsername.isEmpty || password.isEmpty) return null;

    final user = await _userRepository.getUserByUsername(cleanUsername);
    if (user == null) return null;

    if (!PasswordUtil.verify(password, user.passwordHash)) {
      return null;
    }

    _session.set(user);
    return user;
  }

  void logout() {
    _session.clear();
  }

  Future<bool> isUsernameAvailable(String username) {
    return _userRepository.isUsernameTaken(username).then((t) => !t);
  }
}
