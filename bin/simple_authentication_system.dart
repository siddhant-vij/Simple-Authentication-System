import 'dart:io';
import 'package:simple_authentication_system/controllers/auth_controller.dart';
import 'package:simple_authentication_system/models/user.dart';
import 'package:simple_authentication_system/utils/password_hasher.dart';

void main() {
  final authController = AuthController();

  print("Welcome to the Simple Authentication System!");

  while (true) {
    print("\nChoose an option:");
    print("1. Register");
    print("2. Login");
    print("3. Reset Password");
    print("4. Quit");

    var choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        _register(authController);
        break;

      case '2':
        _login(authController);
        break;

      case '3':
        _resetPassword(authController);
        break;

      case '4':
        print("Goodbye!");
        exit(0);

      default:
        print("Invalid choice. Please choose again.");
        break;
    }
  }
}

void _register(AuthController authController) {
  String? username = _getInput("Enter username: ");
  if (username == null || authController.findUserByUsername(username) != null) {
    print("Username already exists or is invalid. Try another one.");
    return;
  }
  if (username.trim().isEmpty) {
    print("Blank username not allowed. Try another one.");
    return;
  }

  String? password = _promptPassword("Enter password: ");
  if (password.trim().isEmpty) {
    print("Blank password not allowed. Try another one.");
    return;
  }

  authController.registerUser(username, password);
  print("Successfully registered!");
}

void _login(AuthController authController) {
  String? usernameLogin = _getInput("Enter username: ");
  if (usernameLogin == null ||
      authController.findUserByUsername(usernameLogin) == null) {
    print("Username doesn't exist or is invalid.");
    return;
  }

  String? passwordLogin = _promptPassword("Enter password: ");

  try {
    authController.loginUser(usernameLogin, passwordLogin);
    print("Successfully logged in!");
  } catch (e) {
    print(e.toString());
  }
}

void _resetPassword(AuthController authController) {
  String? usernameReset = _getInput("Enter username for password reset: ");
  if (usernameReset == null) {
    print("Username input is invalid.");
    return;
  }

  User? existingUser = authController.findUserByUsername(usernameReset);
  if (existingUser == null) {
    print("Username doesn't exist.");
    return;
  }

  String? newPassword;
  bool isSameAsOld;
  do {
    newPassword = _promptPassword("Enter new password: ");

    // Check if new password is the same as the old one
    isSameAsOld =
        PasswordHasher.verifyPassword(newPassword, existingUser.hashedPassword);
    if (isSameAsOld) {
      print(
          "Your new password cannot be the same as your old password. Please try again.");
    }
  } while (isSameAsOld);

  authController.resetPassword(usernameReset, newPassword);
  print("Password successfully reset!");
}

String? _getInput(String prompt) {
  print(prompt);
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
