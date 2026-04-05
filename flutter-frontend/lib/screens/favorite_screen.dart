import 'package:flutter/material.dart';
import 'package:board_game_app/models/board_game.dart';
import 'package:board_game_app/screens/game_detail_screen.dart';
import 'package:board_game_app/utils/game_images.dart';

class FavoritesScreen extends StatefulWidget {
  final List<BoardGame> allGames;
  final VoidCallback onToggleFavorite;
  FavoritesScreen({required this.allGames, required this.onToggleFavorite});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteGames = widget.allGames
        .where((game) => game.isFavorite)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Избранные игры")),
      body: favoriteGames.isEmpty
          ? Center(child: Text("В избранном пока пусто"))
          : ListView.builder(
              itemCount: favoriteGames.length,
              itemBuilder: (context, index) {
                final game = favoriteGames[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      getGameImage(game.id),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image),
                    ),
                  ),
                  title: Text(game.title),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        game.isFavorite = false;
                      });
                      widget.onToggleFavorite();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(game: game),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
