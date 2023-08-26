class User {
  final String id;
  final String username;
  final String hashedPassword;

  User(
      {required this.id, required this.username, required this.hashedPassword});

  // Convert user object to CSV record format
  List<dynamic> toCSV() {
    return [id, username, hashedPassword];
  }

  // Factory constructor to initialize user object from CSV record format
  factory User.fromCSV(List<dynamic> csvRecord) {
    return User(
      id: csvRecord[0] as String,
      username: csvRecord[1] as String,
      hashedPassword: csvRecord[2] as String,
    );
  }
}
