import 'package:test/test.dart';
import 'package:simple_authentication_system/controllers/auth_controller.dart';
import 'package:simple_authentication_system/utils/password_hasher.dart';

void main() {
  final authController = AuthController();

  group('User Registration and Authentication:', () {
    setUp(() {
      // Before each test, ensure there's no user data.
      authController.clearUsers();
    });

    tearDown(() {
      // After each test, ensure there's no user data.
      authController.clearUsers();
    });

    test('Register with valid username and password', () {
      final result = authController.registerUser('testUser', 'testPassword');
      expect(result, isTrue);
    });

    test('Cannot register with an empty username', () {
      final result = authController.registerUser('', 'testPassword');
      expect(result, isFalse);
    });

    test('Cannot register with an empty password', () {
      final result = authController.registerUser('testUser', '');
      expect(result, isFalse);
    });

    test('Cannot register with an existing username', () {
      authController.registerUser('testUser', 'testPassword');
      expect(
          () => authController.registerUser('testUser', 'anotherPassword'),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString() == 'Exception: Username already exists')));
    });

    test('Login with correct credentials', () {
      authController.registerUser('testUser', 'testPassword');
      final user = authController.loginUser('testUser', 'testPassword');
      expect(user, isNotNull);
    });

    test('Cannot login with non-existent username', () {
      try {
        authController.loginUser('nonExistingUser', 'somePassword');
        fail(
            "Expected Exception for non-existing username, but didn't get any.");
      } catch (e) {
        expect(e.toString(), contains('Username not found'));
      }
    });

    test('Cannot login with wrong password for registered username', () {
      authController.registerUser('testUser', 'testPassword');
      try {
        authController.loginUser('testUser', 'wrongPassword');
        fail("Expected Exception for invalid password, but didn't get any.");
      } catch (e) {
        expect(e.toString(), contains('Invalid password'));
      }
    });


    test('Cannot login without registration', () {
      try {
        authController.loginUser('testUser', 'testPassword');
        fail(
            "Expected Exception for non-existing username, but didn't get any.");
      } catch (e) {
        expect(e.toString(), contains('Username not found'));
      }
    });

    test('Password is not stored in plain text', () {
      authController.registerUser('testUser', 'testPassword');
      final user = authController.findUserByUsername('testUser');
      expect(user!.hashedPassword, isNot('testPassword'));
      expect(user.hashedPassword, PasswordHasher.hashPassword('testPassword'));
    });

    test('Reset password for an existing user', () {
      authController.registerUser('testUser', 'testPassword');
      final resetSuccess =
          authController.resetPassword('testUser', 'newPassword');
      expect(resetSuccess, isTrue);
    });

    test('Cannot reset password for non-existent username', () {
      try {
        authController.resetPassword('nonExistingUser', 'somePassword');
        fail("Expected an Exception to be thrown");
      } catch (e) {
        expect(e.toString(), contains('Username not found'));
      }
    });

    test('Cannot login with old password after reset', () {
      authController.registerUser('testUser', 'testPassword');
      authController.resetPassword('testUser', 'newPassword');
      try {
        authController.loginUser('testUser', 'testPassword');
        fail('Expected an Exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Invalid password'));
      }
    });


    test('Can login with new password after reset', () {
      authController.registerUser('testUser', 'testPassword');
      authController.resetPassword('testUser', 'newPassword');
      final user = authController.loginUser('testUser', 'newPassword');
      expect(user, isNotNull);
    });
  });
}
