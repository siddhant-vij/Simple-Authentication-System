import 'dart:io';
import 'package:simple_authentication_system/models/user.dart';
import 'package:simple_authentication_system/utils/csv_handler.dart';
import 'package:simple_authentication_system/utils/password_hasher.dart';
import 'package:simple_authentication_system/utils/exceptions.dart';

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

  String? _getInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync();
  }

  String _promptPassword(String promptText) {
    stdout.write(promptText);
    stdin.echoMode = false;
    final password = stdin.readLineSync();
    stdin.echoMode = true;
    print(''); // move to a new line after input
    return password ?? '';
  }

  void register() {
    String? username = _getInput("Enter username: ");
    if (username == null || findUserByUsername(username) != null) {
      print("Username already exists or is invalid. Try another one.");
      return;
    }
    if (username.trim().isEmpty) {
      print("Blank username not allowed. Try another one.");
      return;
    }

    String? password;

    do {
      password = _promptPassword("Enter password: ");
      if (password.trim().isEmpty) {
        print("Blank password not allowed. Try another one.");
        continue;
      }
      if (!isPasswordStrong(password)) {
        print(
            "Your password is too weak. It should have at least 8 characters, one uppercase, one lowercase, one number, and one special character.");
      }
    } while (!isPasswordStrong(password));

    String? securityQuestion = _getInput(
        "Enter a security question (e.g., 'What's your pet's name?'): ");
    if (securityQuestion == null || securityQuestion.trim().isEmpty) {
      print("Security question cannot be blank.");
      return;
    }

    String? securityAnswer =
        _getInput("Enter the answer for your security question: ");
    if (securityAnswer == null || securityAnswer.trim().isEmpty) {
      print("Security answer cannot be blank.");
      return;
    }

    registerUser(username, password, securityQuestion, securityAnswer);

    print("Successfully registered!");
  }

  bool registerUser(String username, String password, String securityQuestion,
      String securityAnswer) {
    final existingUser = findUserByUsername(username);
    try {
      if (existingUser != null) throw UsernameExistsException();
    } on UsernameExistsException catch (e) {
      print(e);
      return false;
    }
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

  User? login(User? currentUser) {
    String? usernameLogin = _getInput("Enter username: ");
    if (usernameLogin == null || findUserByUsername(usernameLogin) == null) {
      print("Username doesn't exist or is invalid.");
      return null;
    }

    String? passwordLogin = _promptPassword("Enter password: ");

    User? user = loginUser(usernameLogin, passwordLogin);
    currentUser = user;
    return currentUser;
  }

  User? loginUser(String username, String password) {
    final user = findUserByUsername(username);
    try {
      if (user == null) {
        _incrementFailedAttempts(username);
        throw UserNotFoundException();
      }
    } on UserNotFoundException catch (e) {
      print(e);
    }
    try {
      if (!PasswordHasher.verifyPassword(password, user!.hashedPassword)) {
        _incrementFailedAttempts(username);
        throw InvalidPasswordException();
      } else {
        print("Successfully logged in!");
        _resetFailedAttempts(username);
        return user;
      }
    } on InvalidPasswordException catch (e) {
      print(e);
    }
    try {
      if (_lockoutEndTimes.containsKey(username) &&
          DateTime.now().isBefore(_lockoutEndTimes[username]!)) {
        throw AccountLockedException();
      }
    } on AccountLockedException catch (e) {
      print(e);
    }
    return null;
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

  void resetPassword(String? usernameReset) {
    if (usernameReset == null) {
      usernameReset = _getInput("Enter username for password reset: ");
      if (usernameReset == null) {
        print("Username input is invalid.");
        return;
      }
    }

    User? existingUser = findUserByUsername(usernameReset);
    if (existingUser == null) {
      print("Username doesn't exist.");
      return;
    }

    String? newPassword;
    bool isSameAsOld = true;
    do {
      newPassword = _promptPassword("Enter new password: ");
      if (newPassword.trim().isEmpty) {
        print("Blank password not allowed. Try another one.");
        continue;
      }
      if (!isPasswordStrong(newPassword)) {
        print(
            "Your password is too weak. It should have at least 8 characters, one uppercase, one lowercase, one number, and one special character.");
        continue;
      }

      // Check if new password is the same as the old one
      isSameAsOld = PasswordHasher.verifyPassword(
          newPassword, existingUser.hashedPassword);
      if (isSameAsOld) {
        print(
            "Your new password cannot be the same as your old password. Please try again.");
      }
    } while (isSameAsOld);

    resetPwd(usernameReset, newPassword);
    print("Password successfully reset!");
  }

  bool resetPwd(String username, String newPassword) {
    final users = getUsers();
    final hashedNewPassword = PasswordHasher.hashPassword(newPassword);
    int userIndex = users.indexWhere((user) => user.username == username);

    try {
      if (userIndex == -1) throw UserNotFoundException();
    } on UserNotFoundException catch (e) {
      print(e);
    }
    try {
      if (newPassword.trim().isEmpty) {
        throw InvalidPasswordFormatException();
      }
    } on InvalidPasswordFormatException catch (e) {
      print(e);
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

  void forgotPassword() {
    String? username = _getInput("Enter your username: ");
    if (username == null) {
      print("Username input is invalid. Try another one.");
      return;
    }

    User? user = findUserByUsername(username);
    if (user == null) {
      print("Username doesn't exist.");
      return;
    }

    print("Security Question: ${user.securityQuestion}");
    String? answer = _getInput("Enter your answer: ");
    if (answer == null) {
      print("Answer cannot be blank.");
      return;
    }
    if (validateSecurityAnswer(answer, user.securityAnswer)) {
      resetPassword(username);
    } else {
      print("Incorrect answer. Please try again.");
    }
  }

  void deleteUserByUsername(String? username) {
    List<List<dynamic>> csvUsers = _userHandler.readCSV();
    List<User> users = csvUsers.map((record) => User.fromCSV(record)).toList();
    users.removeWhere((user) => user.username == username);
    List<List<dynamic>> updatedCsvUsers =
        users.map((user) => user.toCSV()).toList();
    _userHandler.writeCSV(updatedCsvUsers);
  }

  User? deleteAccount(String? usernameDelete) {
    if (usernameDelete == null) {
      print("Username input is invalid. Try another one.");
      return null;
    }

    User? existingUser = findUserByUsername(usernameDelete);
    if (existingUser == null) {
      print("Username doesn't exist.");
      return null;
    }

    String? passwordDelete =
        _promptPassword("Enter your password for verification: ");
    if (PasswordHasher.verifyPassword(
        passwordDelete, existingUser.hashedPassword)) {
      deleteUserByUsername(usernameDelete);
      print("Account successfully deleted!");
      return null;
    } else {
      print("Incorrect password. Account deletion aborted.");
      return existingUser;
    }
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
