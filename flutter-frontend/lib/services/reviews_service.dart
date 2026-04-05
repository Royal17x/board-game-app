import 'dart:convert';
import 'package:board_game_app/models/reviews.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://192.168.0.26:8080';

class ReviewLimitException implements Exception {
  final String message;
  ReviewLimitException(this.message);
}

class ReviewsService {
  Future<List<Review>> fetchReviews(int gameId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/games/$gameId/reviews'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить отзывы');
  }

  Future<Review> createReview({
    required int gameId,
    required int userId,
    required String text,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/games/$gameId/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'text': text}),
    );
    if (response.statusCode == 201) {
      return Review.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 429) {
      final error = jsonDecode(response.body);
      throw ReviewLimitException(error['error']);
    }
    throw Exception('Ошибка при добавлении отзыва');
  }
}

final reviewsService = ReviewsService();
