import 'dart:io';
import 'package:simple_authentication_system/controllers/auth_controller.dart';
import 'package:simple_authentication_system/models/user.dart';

void main() {
  final app = SimpleAuthSystem();
  app.start();
}

class SimpleAuthSystem {
  final authController = AuthController();
  User? currentUser;

  void _displayMenu(User? currentUser) {
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
      _displayMenu(currentUser);
      String? choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          if (currentUser == null) {
            authController.register();
          } else {
            authController.register(); // Register another account
          }
          break;

        case '2':
          if (currentUser == null) {
            currentUser = authController.login(currentUser);
          } else {
            authController.resetPassword(currentUser!.username);
          }
          break;

        case '3':
          if (currentUser == null) {
            authController.forgotPassword();
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
            currentUser = authController.deleteAccount(currentUser!.username);
          }
          break;

        default:
          print("Invalid choice. Please choose again.");
          break;
      }
    }
  }
}
