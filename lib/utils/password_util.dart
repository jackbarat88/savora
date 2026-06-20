import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtil {
  PasswordUtil._();

  static String hash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verify(String password, String storedHash) {
    return hash(password) == storedHash;
  }
}
