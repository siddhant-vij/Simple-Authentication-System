import 'package:simple_authentication_system/models/user.dart';
import 'package:simple_authentication_system/utils/csv_handler.dart';
import 'package:simple_authentication_system/utils/password_hasher.dart';

class AuthController {
  final _userHandler = CSVHandler("data/users.csv");

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

    final hashedPassword = PasswordHasher.hashPassword(password);
    final newUser = User(
        id: DateTime.now().toIso8601String(),
        username: username,
        hashedPassword: hashedPassword,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer);
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
    final user = findUserByUsername(username);
    if (user == null) throw Exception('Username not found');
    if (!PasswordHasher.verifyPassword(password, user.hashedPassword)) {
      throw Exception('Invalid password');
    }
    return user;
  }

  bool resetPassword(String username, String newPassword) {
    final users = getUsers();
    final hashedNewPassword = PasswordHasher.hashPassword(newPassword);
    int userIndex = users.indexWhere((user) => user.username == username);

    if (userIndex == -1) throw Exception('Username not found');

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
}
