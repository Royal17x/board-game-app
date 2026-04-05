class BoardGame {
  final int id;
  final String title;
  final String description;
  bool isFavorite;
  final String imageUrl;

  BoardGame({
    required this.id,
    required this.title,
    required this.description,
    this.isFavorite = false,
    required this.imageUrl,
  });

  factory BoardGame.fromJson(Map<String, dynamic> json) {
    return BoardGame(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
