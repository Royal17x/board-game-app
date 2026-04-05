enum Role { admin, client }

class User {
  final int id;
  final String username;
  final Role role;
  final DateTime createdAt;

  User({
    this.id = 0,
    required this.username,
    this.role = Role.client,
    required this.createdAt,
  });

  bool get isAdmin => role == Role.admin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] == 'admin' ? Role.admin : Role.client,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
