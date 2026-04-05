import 'package:board_game_app/utils/game_images.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/models/board_game.dart';
import 'package:board_game_app/models/reviews.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:board_game_app/services/reviews_service.dart';

class GameDetailScreen extends StatefulWidget {
  final BoardGame game;
  GameDetailScreen({required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final TextEditingController reviewController = TextEditingController();
  List<Review> _reviews = [];
  bool _loadingReviews = true;
  String? _reviewError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final reviews = await reviewsService.fetchReviews(widget.game.id);
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    } catch (e) {
      setState(() => _loadingReviews = false);
    }
  }

  void _addReview() async {
    final text = reviewController.text.trim();
    if (text.isEmpty) return;

    if (!authState.isLoggedIn) {
      setState(() => _reviewError = 'Войдите, чтобы оставить отзыв');
      return;
    }

    setState(() {
      _submitting = true;
      _reviewError = null;
    });

    try {
      await reviewsService.createReview(
        gameId: widget.game.id,
        userId: authState.currentUser!.id,
        text: text,
      );
      reviewController.clear();
      _loadReviews();
    } on ReviewLimitException catch (e) {
      setState(() => _reviewError = e.message);
    } catch (e) {
      setState(() => _reviewError = 'Ошибка при отправке отзыва');
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.game.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: Image.asset(
                getGameImage(widget.game.id),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.game.title,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(widget.game.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Divider(),
                  Text(
                    "Отзывы:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _loadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                      ? Text("Пока нет отзывов. Будьте первым!")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final r = _reviews[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(r.text),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 20),
                  Text(
                    "Оставить отзыв:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: reviewController,
                          enabled: authState.isLoggedIn,
                          decoration: InputDecoration(
                            hintText: authState.isLoggedIn
                                ? "Напишите что-то об игре..."
                                : "Войдите, чтобы оставить отзыв",
                          ),
                        ),
                      ),
                      _submitting
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.send, color: Colors.blue),
                              onPressed: authState.isLoggedIn
                                  ? _addReview
                                  : null,
                            ),
                    ],
                  ),
                  if (_reviewError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _reviewError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Игра успешно забронирована!"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        "Забронировать Игру",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
