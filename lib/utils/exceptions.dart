class UsernameExistsException implements Exception {
  final String msg;
  UsernameExistsException({this.msg = 'Username already exists'});
  @override
  String toString() => 'UsernameExistsException: $msg';
}

class AccountLockedException implements Exception {
  final String msg;
  AccountLockedException(
      {this.msg =
          'Account is locked due to multiple failed attempts. Please wait and try again later.'});
  @override
  String toString() => 'AccountLockedException: $msg';
}

class UserNotFoundException implements Exception {
  final String msg;
  UserNotFoundException({this.msg = 'Username not found'});
  @override
  String toString() => 'UserNotFoundException: $msg';
}

class InvalidPasswordException implements Exception {
  final String msg;
  InvalidPasswordException({this.msg = 'Invalid password'});
  @override
  String toString() => 'InvalidPasswordException: $msg';
}

class InvalidPasswordFormatException implements Exception {
  final String msg;
  InvalidPasswordFormatException({this.msg = 'Invalid password format'});
  @override
  String toString() => 'InvalidPasswordFormatException: $msg';
}
