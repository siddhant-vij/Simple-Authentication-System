class User {
  final String id;
  final String username;
  final String hashedPassword;
  final String securityQuestion;
  final String securityAnswer;

  User(
      {required this.id,
      required this.username,
      required this.hashedPassword,
      required this.securityQuestion,
      required this.securityAnswer});

  // Convert user object to CSV record format
  List<dynamic> toCSV() {
    return [id, username, hashedPassword, securityQuestion, securityAnswer];
  }

  // Factory constructor to initialize user object from CSV record format
  factory User.fromCSV(List<dynamic> csvRecord) {
    return User(
      id: csvRecord[0] as String,
      username: csvRecord[1] as String,
      hashedPassword: csvRecord[2] as String,
      securityQuestion: csvRecord[3] as String,
      securityAnswer: csvRecord[4] as String,
    );
  }
}
