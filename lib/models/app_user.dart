class AppUser {
  const AppUser({
    this.id,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  final int? id;
  final String email;
  final String password;
  final DateTime createdAt;

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
