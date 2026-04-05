class Review {
  final int id;
  final int gameId;
  final int userId;
  final String username;
  final String text;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      gameId: json['game_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      text: json['text'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
