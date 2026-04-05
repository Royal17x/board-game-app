import 'package:board_game_app/utils/game_images.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/models/board_game.dart';
import 'package:board_game_app/models/reviews.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:board_game_app/services/reviews_service.dart';
import 'package:board_game_app/services/bookings_service.dart';
import 'package:board_game_app/screens/booking_screen.dart';
import 'package:board_game_app/services/games_service.dart';

class GameDetailScreen extends StatefulWidget {
  final BoardGame game;
  GameDetailScreen({required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  // Отзывы
  final TextEditingController reviewController = TextEditingController();
  List<Review> _reviews = [];
  bool _loadingReviews = true;
  String? _reviewError;
  bool _submitting = false;

  // Бронирование
  bool _booking = false;
  String? _bookingMessage;
  bool _bookingSuccess = false;

  // Для редактирования
  late BoardGame _game;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _loadReviews();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
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

  void _bookGame() async {
    if (!authState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите, чтобы забронировать игру')),
      );
      return;
    }
    setState(() {
      _booking = true;
      _bookingMessage = null;
    });
    try {
      await bookingsService.createBooking(
        userId: authState.currentUser!.id,
        gameId: widget.game.id,
      );
      setState(() {
        _bookingMessage = 'Игра успешно забронирована';
        _bookingSuccess = true;
      });
    } catch (e) {
      setState(() {
        _bookingMessage = e.toString().replaceAll('Exception: ', '');
        _bookingSuccess = false;
      });
    } finally {
      setState(() => _booking = false);
    }
  }

  void _showEditDialog() {
    final titleCtrl = TextEditingController(text: _game.title);
    final descCtrl = TextEditingController(text: _game.description);
    final imageCtrl = TextEditingController(text: _game.imageUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Редактировать игру"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: "Название"),
            ),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(labelText: "Описание"),
            ),
            TextField(
              controller: imageCtrl,
              decoration: InputDecoration(labelText: "URL картинки"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await gamesService.updateGame(
                  adminId: authState.currentUser!.id,
                  gameId: widget.game.id,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: imageCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                setState(() {
                  _game = BoardGame(
                    id: _game.id,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    imageUrl: imageCtrl.text.trim(),
                    isFavorite: _game.isFavorite,
                  );
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Игра обновлена')));
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_game.title),
        actions: [
          if (authState.currentUser?.isAdmin ?? false)
            IconButton(
              onPressed: _showEditDialog,
              icon: Icon(Icons.edit),
              tooltip: "Редактировать",
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Картинка
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: Image.asset(
                getGameImage(widget.game.id),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
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
                  // Название и описание
                  Text(
                    _game.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_game.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  const Divider(),

                  // Кнопки бронирования
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _booking ? null : _bookGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _booking
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Забронировать',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BookingsScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Мои брони'),
                      ),
                    ],
                  ),

                  // Сообщение о результате бронирования
                  if (_bookingMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _bookingMessage!,
                      style: TextStyle(
                        color: _bookingSuccess ? Colors.green : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),

                  // Отзывы
                  const Text(
                    'Отзывы:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _loadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                      ? const Text('Пока нет отзывов. Будьте первым!')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final r = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
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

                  const SizedBox(height: 20),

                  // Форма отзыва
                  const Text(
                    'Оставить отзыв:',
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
                                ? 'Напишите что-то об игре...'
                                : 'Войдите, чтобы оставить отзыв',
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
                              icon: const Icon(Icons.send, color: Colors.blue),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
