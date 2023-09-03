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

    test('Cannot register with whitespace-only username', () {
      final result = authController.registerUser(
          '   ', 'testPassword', 'testQuestion', 'testAnswer');
      expect(result, isFalse);
    });

    test('Cannot register with whitespace-only password', () {
      final result = authController.registerUser(
          'testUser', '    ', 'testQuestion', 'testAnswer');
      expect(result, isFalse);
    });
    test('Cannot register with whitespace-only password', () {
      final result = authController.registerUser(
          'testUser', '    ', 'testQuestion', 'testAnswer');
      expect(result, isFalse);
    });

    test('Cannot register with a security question but no answer', () {
      final result = authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', '  ');
      expect(result, isFalse);
    });

    test('Register with valid username and password', () {
      final result = authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      expect(result, isTrue);
    });

    test('Cannot register with an empty username', () {
      final result = authController.registerUser(
          '', 'testPassword', 'testQuestion', 'testAnswer');
      expect(result, isFalse);
    });

    test('Cannot register with an empty password', () {
      final result = authController.registerUser(
          'testUser', '', 'testQuestion', 'testAnswer');
      expect(result, isFalse);
    });

    test('Cannot register with an existing username', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      expect(
          () => authController.registerUser(
              'testUser', 'anotherPassword', 'testQuestion', 'testAnswer'),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString() == 'Exception: Username already exists')));
    });

    test('Cannot login with whitespace-only username', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      try {
        authController.loginUser('   ', 'testPassword');
        fail('Expected an Exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Username not found'));
      }
    });

    test('Login is case-sensitive', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      try {
        authController.loginUser('TestUser', 'testPassword');
        fail('Expected an Exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Username not found'));
      }
    });

    test('Login with correct credentials', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
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
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
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
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      final user = authController.findUserByUsername('testUser');
      expect(user!.hashedPassword, isNot('testPassword'));
      expect(user.hashedPassword, PasswordHasher.hashPassword('testPassword'));
    });

    test('Cannot reset with whitespace-only new password', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      try {
        authController.resetPassword('testUser', '   ');
        fail('Expected an Exception to be thrown');
      } catch (e) {
        // Assuming you'll have a mechanism to throw an exception for invalid password
        expect(e.toString(), contains('Invalid password format'));
      }
    });

    test('Cannot reset with a very short password', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      final passwordStrength = authController.isPasswordStrong('test');
      expect(passwordStrength, isFalse);
    });

    test(
        'Can reset with a strong password - 8 characters, 1 uppercase, 1 lowercase, 1 number, and 1 special character',
        () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      final passwordStrength = authController.isPasswordStrong('Test@1234');
      expect(passwordStrength, isTrue);
    });

    test('Reset password for an existing user', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
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
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      authController.resetPassword('testUser', 'newPassword');
      try {
        authController.loginUser('testUser', 'testPassword');
        fail('Expected an Exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Invalid password'));
      }
    });

    test('Can login with new password after reset', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      authController.resetPassword('testUser', 'newPassword');
      final user = authController.loginUser('testUser', 'newPassword');
      expect(user, isNotNull);
    });

    test('Successful deletion of a user', () {
      authController.registerUser(
          'deleteUser', 'testPassword', 'testQuestion', 'testAnswer');
      authController.deleteUserByUsername('deleteUser');
      final user = authController.findUserByUsername('deleteUser');
      expect(user, isNull);
    });

    test('Cannot login after user deletion', () {
      authController.registerUser(
          'deleteUser', 'testPassword', 'testQuestion', 'testAnswer');
      authController.deleteUserByUsername('deleteUser');
      try {
        authController.loginUser('deleteUser', 'testPassword');
        fail('Expected an Exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Username not found'));
      }
    });

    test('Deletion of non-existent user does not affect other users', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');
      authController.deleteUserByUsername('nonExistingUser');
      final user = authController.findUserByUsername('testUser');
      expect(user, isNotNull);
    });

    test('Successful password recovery with correct answer', () {
      authController.registerUser(
          'testUser', 'testPassword', 'What is your pet\'s name?', 'Buddy');
      final user = authController.findUserByUsername('testUser');
      expect(user?.securityQuestion, 'What is your pet\'s name?');
      expect(user?.securityAnswer, PasswordHasher.hashPassword('Buddy'));
    });

    test('Failed password recovery with incorrect answer', () {
      authController.registerUser(
          'testUser', 'testPassword', 'What is your pet\'s name?', 'Buddy');
      final user = authController.findUserByUsername('testUser');
      expect(
          user?.securityAnswer, isNot(PasswordHasher.hashPassword('NotBuddy')));
    });

    test('Registration with special characters', () {
      final result = authController.registerUser(
          'test@User!', 'test#Password!', 'testQuestion', 'testAnswer');
      expect(result, isTrue);
      final user = authController.findUserByUsername('test@User!');
      expect(user, isNotNull);
    });

    test('Registration with very long username or password', () {
      final longUsername = 'a' * 200;
      final longPassword = 'b' * 200;
      final result = authController.registerUser(
          longUsername, longPassword, 'testQuestion', 'testAnswer');
      expect(result, isTrue);
      final user = authController.findUserByUsername(longUsername);
      expect(user, isNotNull);
    });

    test('Cannot provide whitespace-only security answer', () {
      final result = authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', '   ');
      expect(result, isFalse);
    });

    test('Security answer is case insensitive', () {
      authController.registerUser(
          'testUser', 'testPassword', 'What is your pet\'s name?', 'Buddy');
      final hashedPassword = PasswordHasher.hashPassword('buddy');
      final isValidAnswer =
          authController.validateSecurityAnswer('buddy', hashedPassword);
      expect(isValidAnswer, isTrue);
    });

    test('After max failed attempts, user should be locked out', () {
      for (int i = 0; i < AuthController.maxFailedAttempts; i++) {
        expect(() => authController.loginUser("testUser", 'wrongPassword'),
            throwsException);
      }

      expect(
          () => authController.loginUser('testUser', 'wrongPassword'),
          throwsA(predicate((e) =>
              e.toString() ==
              'Exception: Account is locked due to multiple failed attempts. Please wait and try again later.')));
    });

    test('After successful login, failed attempts should reset', () {
      authController.registerUser(
          'testUser', 'testPassword', 'testQuestion', 'testAnswer');

      for (int i = 0; i < AuthController.maxFailedAttempts - 1; i++) {
        expect(() => authController.loginUser('testUser', 'wrongPassword'),
            throwsException);
      }

      authController.loginUser('testUser', 'testPassword');

      expect(() => authController.loginUser('testUser', 'wrongPassword'),
          throwsException);
      expect(() => authController.loginUser('testUser', 'wrongPassword'),
          throwsException);
      expect(() => authController.loginUser('testUser', 'wrongPassword'),
          throwsException);
      expect(
          () => authController.loginUser('testUser', 'wrongPassword'),
          throwsA(predicate((e) =>
              e.toString() ==
              'Exception: Account is locked due to multiple failed attempts. Please wait and try again later.')));
    });
  });
}
