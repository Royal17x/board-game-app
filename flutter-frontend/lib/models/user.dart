class User {
  final int id;
  final String username;
  final String? password;
  final Role role;
  final DateTime createdAt;

  User({
    this.id = 0,
    required this.username,
    this.password,
    this.role = Role.client,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

enum Role { admin, client }
