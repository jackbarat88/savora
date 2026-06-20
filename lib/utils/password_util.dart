import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility untuk secure password hashing dan verification
/// Menggunakan SHA-256 algorithm untuk transform password ke hash
class PasswordUtil {
  PasswordUtil._();

  /// Hash password dengan SHA-256 untuk secure storage
  /// Password tidak pernah disimpan plaintext ke database
  static String hash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password dengan membandingkan hash
  /// Return true kalau password match, false otherwise
  static bool verify(String password, String storedHash) {
    return hash(password) == storedHash;
  }
}
