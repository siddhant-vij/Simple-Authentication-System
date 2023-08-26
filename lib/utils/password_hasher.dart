import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static bool verifyPassword(String inputPassword, String storedHash) {
    return hashPassword(inputPassword) == storedHash;
  }
}
