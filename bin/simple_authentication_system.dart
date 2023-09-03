import 'dart:io';
import 'package:simple_authentication_system/controllers/auth_controller.dart';
import 'package:simple_authentication_system/models/user.dart';
import 'package:simple_authentication_system/utils/password_hasher.dart';

void main() {
  final app = SimpleAuthSystem();
  app.start();
}

class SimpleAuthSystem {
  final authController = AuthController();
  User? currentUser;

  void _displayMenu() {
    print("\n\nWelcome to the Simple Authentication System\n");

    if (currentUser == null) {
      print("1. Register");
      print("2. Login");
      print("3. Forgot Password");
      print("4. Quit");
    } else {
      print("1. Register another account");
      print("2. Reset Password");
      print("3. Logout");
      print("4. Delete Account");
    }
  }

  void start() {
    while (true) {
      _displayMenu();
      String? choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          if (currentUser == null) {
            _register(authController);
          } else {
            _register(authController); // Register another account
          }
          break;

        case '2':
          if (currentUser == null) {
            _login(authController);
          } else {
            _resetPassword(authController, currentUser!.username);
          }
          break;

        case '3':
          if (currentUser == null) {
            _forgotPassword(authController);
          } else {
            currentUser = null; // Logout
            print("Successfully logged out!");
          }
          break;

        case '4':
          if (currentUser == null) {
            print("Goodbye!");
            exit(0); // Quit the application
          } else {
            _deleteAccount(authController, currentUser!.username);
            currentUser = null;
          }
          break;

        default:
          print("Invalid choice. Please choose again.");
          break;
      }
    }
  }

  void _register(AuthController authController) {
    String? username = _getInput("Enter username: ");
    if (username == null ||
        authController.findUserByUsername(username) != null) {
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
      if (!authController.isPasswordStrong(password)) {
        print(
            "Your password is too weak. It should have at least 8 characters, one uppercase, one lowercase, one number, and one special character.");
      }
    } while (!authController.isPasswordStrong(password));

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

    authController.registerUser(
        username, password, securityQuestion, securityAnswer);

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
    User? user = authController.loginUser(usernameLogin, passwordLogin);
    currentUser = user;
  }

  void _resetPassword(AuthController authController, String? usernameReset) {
    if (usernameReset == null) {
      usernameReset = _getInput("Enter username for password reset: ");
      if (usernameReset == null) {
        print("Username input is invalid.");
        return;
      }
    }

    User? existingUser = authController.findUserByUsername(usernameReset);
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
      if (!authController.isPasswordStrong(newPassword)) {
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

    authController.resetPassword(usernameReset, newPassword);
    print("Password successfully reset!");
  }

  void _deleteAccount(AuthController authController, String? usernameDelete) {
    if (usernameDelete == null) {
      print("Username input is invalid. Try another one.");
      return;
    }

    User? existingUser = authController.findUserByUsername(usernameDelete);
    if (existingUser == null) {
      print("Username doesn't exist.");
      return;
    }

    String? passwordDelete =
        _promptPassword("Enter your password for verification: ");
    if (PasswordHasher.verifyPassword(
        passwordDelete, existingUser.hashedPassword)) {
      authController.deleteUserByUsername(usernameDelete);
      print("Account successfully deleted!");
      return;
    } else {
      print("Incorrect password. Account deletion aborted.");
    }
  }

  void _forgotPassword(AuthController authController) {
    String? username = _getInput("Enter your username: ");
    if (username == null) {
      print("Username input is invalid. Try another one.");
      return;
    }

    User? user = authController.findUserByUsername(username);
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
    if (authController.validateSecurityAnswer(answer, user.securityAnswer)) {
      _resetPassword(authController, username);
    } else {
      print("Incorrect answer. Please try again.");
    }
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
}
