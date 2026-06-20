import '/models/user_model.dart';
import '/repositories/user_repository.dart';
import '/session/user_session.dart';
import '/utils/password_util.dart';

class AuthService {
  final UserRepository _userRepository;
  final UserSession _session;

  AuthService(this._userRepository, this._session);

  /// Register user baru dengan validasi lengkap:
  /// - Check field kosong
  /// - Validasi password match
  /// - Check username sudah ada atau belum
  /// - Hash password sebelum simpan ke database
  Future<bool> register({
    required String fullName,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    // Normalize username: trim spasi dan lowercase untuk konsistensi
    final cleanUsername = username.trim().toLowerCase();

    // Validasi semua field tidak boleh kosong
    if (fullName.trim().isEmpty ||
        cleanUsername.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return false;
    }

    // Password harus sama dengan confirm password
    if (password != confirmPassword) {
      return false;
    }

    // Cek apakah username sudah dipakai user lain
    if (await _userRepository.isUsernameTaken(cleanUsername)) {
      return false;
    }

    // Create user baru dengan password yang sudah di-hash
    final user = UserModel.create(
      fullName: fullName.trim(),
      username: cleanUsername,
      passwordHash: PasswordUtil.hash(password),
    );
    await _userRepository.addUser(user);
    return true;
  }

  /// Login dengan username & password
  /// Return UserModel kalau login berhasil, null kalau gagal
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    if (cleanUsername.isEmpty || password.isEmpty) return null;

    // Cari user di database berdasarkan username
    final user = await _userRepository.getUserByUsername(cleanUsername);
    if (user == null) return null;

    // Verifikasi password dengan hash yang tersimpan
    if (!PasswordUtil.verify(password, user.passwordHash)) {
      return null;
    }

    // Simpan user ke session untuk akses global
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
