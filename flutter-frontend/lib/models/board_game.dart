class BoardGame {
  final int id;
  final String title;
  final String description;
  bool isFavorite;
  List<String> reviews;
  final String imageUrl;

  BoardGame({
    required this.id,
    required this.title,
    required this.description,
    this.isFavorite = false,
    required this.reviews,
    required this.imageUrl,
  });
}
