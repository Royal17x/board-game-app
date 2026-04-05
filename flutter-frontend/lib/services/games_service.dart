import 'dart:convert';
import 'package:board_game_app/models/board_game.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://192.168.0.26:8080';

class GamesService {
  Future<List<BoardGame>> fetchGames() async {
    final response = await http.get(Uri.parse('$_baseUrl/games'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BoardGame.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить игры');
  }

  Future<BoardGame> createGame({
    required int adminId,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': adminId.toString(),
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode == 201) {
      return BoardGame.fromJson(jsonDecode(response.body));
    }
    throw Exception('Ошибка при создании игры');
  }

  Future<void> deleteGame({required int adminId, required int gameId}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/games/$gameId'),
      headers: {'X-User-Id': adminId.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка при удалении игры');
    }
  }

  Future<void> updateGame({
    required int adminId,
    required int gameId,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': adminId.toString(),
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка при обновлении игры');
    }
  }
}

final gamesService = GamesService();
