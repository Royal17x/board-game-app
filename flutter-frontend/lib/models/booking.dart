class Booking {
  final int id;
  final int userId;
  final int gameId;
  final String gameTitle;
  final DateTime bookedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.gameTitle,
    required this.bookedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      gameId: json['game_id'] ?? 0,
      gameTitle: json['game_title'] ?? '',
      bookedAt: json['booked_at'] != null
          ? DateTime.parse(json['booked_at'])
          : DateTime.now(),
    );
  }
}
