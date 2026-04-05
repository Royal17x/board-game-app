import 'dart:convert';
import 'package:board_game_app/models/board_game.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://192.168.0.26:8080';

class FavoritesService {
  Future<List<BoardGame>> fetchFavorites(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BoardGame.fromJson(e)).toList();
    }
    throw Exception('Ошибка загрузки избранного');
  }

  Future<void> addFavorite(int userId, int gameId) async {
    await http.post(
      Uri.parse('$_baseUrl/favorites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'game_id': gameId}),
    );
  }

  Future<void> removeFavorite(int userId, int gameId) async {
    await http.delete(
      Uri.parse('$_baseUrl/favorites?user_id=$userId&game_id=$gameId'),
    );
  }
}

final favoritesService = FavoritesService();
