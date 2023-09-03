import 'package:simple_authentication_system/models/user.dart';
import 'package:simple_authentication_system/utils/csv_handler.dart';
import 'package:simple_authentication_system/utils/password_hasher.dart';

class AuthController {
  final _userHandler = CSVHandler("data/users.csv");
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockoutEndTimes = {};
  // Change these as needed
  static const int maxFailedAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 3);

  List<User> getUsers() {
    final userRecords = _userHandler.readCSV();
    return userRecords.map((record) => User.fromCSV(record)).toList();
  }

  void clearUsers() {
    _userHandler.writeCSV([]); // Clears the CSV content
  }

  bool registerUser(String username, String password, String securityQuestion,
      String securityAnswer) {
    final existingUser = findUserByUsername(username);
    if (existingUser != null) throw Exception('Username already exists');
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    if (securityAnswer.trim().isEmpty) {
      return false;
    }

    final hashedPassword = PasswordHasher.hashPassword(password);
    final hashedSecurityAnswer = PasswordHasher.hashPassword(securityAnswer);
    final newUser = User(
        id: DateTime.now().toIso8601String(),
        username: username,
        hashedPassword: hashedPassword,
        securityQuestion: securityQuestion,
        securityAnswer: hashedSecurityAnswer);
    _userHandler.writeCSV(
        [...getUsers().map((user) => user.toCSV()).toList(), newUser.toCSV()]);
    return true;
  }

  User? findUserByUsername(String username) {
    final users = getUsers();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  User loginUser(String username, String password) {
    if (_lockoutEndTimes.containsKey(username) &&
        DateTime.now().isBefore(_lockoutEndTimes[username]!)) {
      throw Exception(
          'Account is locked due to multiple failed attempts. Please wait and try again later.');
    }
    final user = findUserByUsername(username);
    if (user == null) {
      _incrementFailedAttempts(username);
      throw Exception('Username not found');
    }
    if (!PasswordHasher.verifyPassword(password, user.hashedPassword)) {
      _incrementFailedAttempts(username);
      throw Exception('Invalid password');
    }
    _resetFailedAttempts(username);
    return user;
  }

  void _incrementFailedAttempts(String username) {
    _failedAttempts[username] = (_failedAttempts[username] ?? 0) + 1;

    if (_failedAttempts[username]! >= maxFailedAttempts) {
      _lockoutEndTimes[username] = DateTime.now().add(lockoutDuration);
    }
  }

  void _resetFailedAttempts(String username) {
    _failedAttempts.remove(username);
    _lockoutEndTimes.remove(username);
  }

  bool resetPassword(String username, String newPassword) {
    final users = getUsers();
    final hashedNewPassword = PasswordHasher.hashPassword(newPassword);
    int userIndex = users.indexWhere((user) => user.username == username);

    if (userIndex == -1) throw Exception('Username not found');
    if (newPassword.trim().isEmpty) {
      throw Exception('Invalid password format');
    }

    User updatedUser = User(
        id: users[userIndex].id,
        username: users[userIndex].username,
        hashedPassword: hashedNewPassword,
        securityQuestion: users[userIndex].securityQuestion,
        securityAnswer: users[userIndex].securityAnswer);
    users[userIndex] = updatedUser;
    _userHandler.writeCSV(users.map((user) => user.toCSV()).toList());
    return true; // Password reset successful
  }

  void deleteUserByUsername(String? username) {
    List<List<dynamic>> csvUsers = _userHandler.readCSV();
    List<User> users = csvUsers.map((record) => User.fromCSV(record)).toList();
    users.removeWhere((user) => user.username == username);
    List<List<dynamic>> updatedCsvUsers =
        users.map((user) => user.toCSV()).toList();
    _userHandler.writeCSV(updatedCsvUsers);
  }

  bool isPasswordStrong(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;

    return hasUppercase &&
        hasDigits &&
        hasLowercase &&
        hasSpecialCharacters &&
        hasMinLength;
  }

  bool validateSecurityAnswer(String s, String t) {
    if (PasswordHasher.verifyPassword(s, t)) {
      return true;
    } else {
      return false;
    }
  }
}
