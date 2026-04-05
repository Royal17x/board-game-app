import 'package:board_game_app/services/games_service.dart';
import 'package:board_game_app/utils/game_images.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/models/board_game.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:board_game_app/screens/game_detail_screen.dart';
import 'package:board_game_app/screens/profile_screen.dart';
import 'package:board_game_app/screens/login_screen.dart';
import 'package:board_game_app/screens/booking_screen.dart';
import 'package:board_game_app/services/favorites_service.dart';
import 'package:board_game_app/screens/favorite_screen.dart';

class BoardGameCatalogScreen extends StatefulWidget {
  @override
  State<BoardGameCatalogScreen> createState() => _BoardGameCatalogScreenState();
}

class _BoardGameCatalogScreenState extends State<BoardGameCatalogScreen> {
  List<BoardGame> allGames = [];
  List<BoardGame> filteredGames = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  String? _loadError;
  String _sortMode = 'default';
  int _visibleCount = 5;

  @override
  void initState() {
    super.initState();
    _loadGames();
    authState.addListener(_onAuthStateChanged);
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final games = await gamesService.fetchGames();
      if (authState.isLoggedIn) {
        final favs = await favoritesService.fetchFavorites(
          authState.currentUser!.id,
        );
        final favIds = favs.map((g) => g.id).toSet();
        for (final g in games) {
          g.isFavorite = favIds.contains(g.id);
        }
      }
      setState(() {
        allGames = games;
        filteredGames = games;
        _applySort(allGames);
        filteredGames = List.from(allGames);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Ошибка загрузки игр';
        _isLoading = false;
      });
    }
  }

  void _onAuthStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    authState.removeListener(_onAuthStateChanged);
    searchController.dispose();
    super.dispose();
  }

  void _applySort(List<BoardGame> games) {
    if (_sortMode == "name") {
      games.sort((a, b) => a.title.compareTo(b.title));
    }
  }

  void _runFilter(String enteredKeyword) {
    List<BoardGame> results = [];
    if (enteredKeyword.isEmpty) {
      results = allGames;
    } else {
      results = allGames
          .where(
            (game) =>
                game.title.toLowerCase().contains(enteredKeyword.toLowerCase()),
          )
          .toList();
      _applySort(allGames);
    }
    setState(() {
      filteredGames = results;
    });
  }

  void _openAccountLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            authState.isLoggedIn ? ProfileScreen() : LoginScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  void _showAddGameDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить игру'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: imageCtrl,
              decoration: const InputDecoration(labelText: 'URL картинки'),
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
                await gamesService.createGame(
                  adminId: authState.currentUser!.id,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: imageCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                _loadGames();
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _deleteGame(int gameId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить игру?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await gamesService.deleteGame(
          adminId: authState.currentUser!.id,
          gameId: gameId,
        );
        _loadGames();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = authState.currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text("Бронирование игр"),
        actions: [
          if (authState.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.bookmark),
              tooltip: 'Мои бронирования',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingsScreen()),
              ),
            ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    allGames: allGames,
                    onToggleFavorite: () {
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              authState.isLoggedIn ? Icons.account_circle : Icons.login,
              color: authState.isLoggedIn ? Colors.amber : null,
            ),
            tooltip: authState.isLoggedIn
                ? authState.currentUser?.username ?? "Кабинет"
                : "Войти",
            onPressed: _openAccountLoginScreen,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: "Поиск игр (например, Монополия...)",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showAddGameDialog,
              icon: const Icon(Icons.add),
              label: const Text('Добавить игру'),
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_loadError!),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadGames,
                    child: Text('Повторить'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Панель сортировки
                Container(
                  color: Colors.grey[100],
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Text('Сортировка:', style: TextStyle(fontSize: 13)),
                      Radio<String>(
                        value: 'default',
                        groupValue: _sortMode,
                        activeColor: Colors.indigo,
                        onChanged: (val) {
                          setState(() {
                            _sortMode = val!;
                            _visibleCount = 5;
                          });
                          _loadGames();
                        },
                      ),
                      Text('По умолчанию', style: TextStyle(fontSize: 13)),
                      Radio<String>(
                        value: 'name',
                        groupValue: _sortMode,
                        activeColor: Colors.indigo,
                        onChanged: (val) {
                          setState(() {
                            _sortMode = val!;
                            _visibleCount = 5;
                            final sorted = List<BoardGame>.from(allGames)
                              ..sort((a, b) => a.title.compareTo(b.title));
                            filteredGames = sorted;
                          });
                        },
                      ),
                      Text('По названию', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                // Сетка игр
                Expanded(
                  child: filteredGames.isEmpty
                      ? Center(child: Text('Игры не найдены'))
                      : GridView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: filteredGames.length > _visibleCount
                              ? _visibleCount + 1
                              : filteredGames.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            // Кнопка "Показать ещё"
                            if (index == _visibleCount &&
                                filteredGames.length > _visibleCount) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        setState(() => _visibleCount += 5),
                                    child: Text('Показать ещё'),
                                  ),
                                ),
                              );
                            }

                            final game = filteredGames[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GameDetailScreen(game: game),
                                  ),
                                );
                                _loadGames();
                                setState(() {});
                              },
                              child: Card(
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            color: Colors.grey[300],
                                            child: Image.asset(
                                              getGameImage(game.id),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                          if (isAdmin)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _deleteGame(game.id),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  padding: EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            game.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          IconButton(
                                            icon: Icon(
                                              game.isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: game.isFavorite
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () async {
                                              if (!authState.isLoggedIn) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Войдите, чтобы добавить в избранное',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              final newValue = !game.isFavorite;
                                              setState(
                                                () =>
                                                    game.isFavorite = newValue,
                                              );
                                              if (newValue) {
                                                await favoritesService
                                                    .addFavorite(
                                                      authState.currentUser!.id,
                                                      game.id,
                                                    );
                                              } else {
                                                await favoritesService
                                                    .removeFavorite(
                                                      authState.currentUser!.id,
                                                      game.id,
                                                    );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
