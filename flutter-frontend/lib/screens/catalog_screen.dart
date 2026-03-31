import 'package:flutter/material.dart';
import 'package:board_game_app/models/board_game.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:board_game_app/screens/game_detail_screen.dart';
import 'package:board_game_app/screens/profile_screen.dart';
import 'package:board_game_app/screens/favorite_screen.dart';
import 'package:board_game_app/screens/login_screen.dart';

class BoardGameCatalogScreen extends StatefulWidget {
  @override
  State<BoardGameCatalogScreen> createState() => _BoardGameCatalogScreenState();
}

List<String> urlList = [
  "https://cdn.pixabay.com/photo/2016/11/29/02/05/monopoly-1866978_640.jpg",
  "https://cdn.pixabay.com/photo/2020/06/08/15/01/catan-5274293_640.jpg",
  "https://cdn.pixabay.com/photo/2022/09/12/12/50/board-game-7448610_640.jpg",
  "https://cdn.pixabay.com/photo/2017/05/21/22/17/carcassonne-2332158_640.jpg",
  "https://cdn.pixabay.com/photo/2019/07/13/07/58/munchkin-4334402_640.jpg",
  "https://cdn.pixabay.com/photo/2017/08/06/22/01/arkham-horror-2595734_640.jpg",
  "https://cdn.pixabay.com/photo/2018/03/22/17/07/dixit-3250547_640.jpg",
  "https://cdn.pixabay.com/photo/2018/09/16/14/29/pandemic-3681351_640.jpg",
  "https://cdn.pixabay.com/photo/2017/12/16/19/54/codenames-3025182_640.jpg",
  "https://cdn.pixabay.com/photo/2016/11/18/14/04/mafia-1835471_640.jpg",
  "https://cdn.pixabay.com/photo/2020/01/27/12/47/uno-4797275_640.jpg",
  "https://cdn.pixabay.com/photo/2016/03/27/22/23/evolution-1284167_640.jpg",
  "https://cdn.pixabay.com/photo/2016/11/22/23/44/chess-1851019_640.jpg",
  "https://cdn.pixabay.com/photo/2019/09/18/15/52/jenga-4487006_640.jpg",
  "https://cdn.pixabay.com/photo/2016/11/29/04/21/scrabble-1867514_640.jpg",
  "https://cdn.pixabay.com/photo/2017/01/31/23/14/clue-2028320_640.jpg",
];

List<String> descriptionList = [
  "Классическая игра про торговлю недвижимостью.",
  "Стратегия про строительство поселений и обмен ресурсами.",
  "Стройте железнодорожные маршруты по всему миру.",
  "Строительство средневековых замков и дорог.",
  "Пародия на ролевые игры. Мочи монстров, хапай сокровища.",
  "Кооперативная игра по мифам Лавкрафта.",
  "Игра в ассоциации с сюрреалистичными картинками.",
  "Спасите мир от четырех смертельных болезней.",
  "Командная игра в слова для шпионов.",
  "Психологическая ролевая игра с детективным сюжетом.",
  "Быстрая карточная игра для любой компании.",
  "Создавайте своих существ и помогайте им выжить.",
  "Древняя логическая игра.",
  "Стройте башню и не дайте ей упасть.",
  "Составляйте слова и зарабатывайте очки.",
  "Классический детектив. Найдите убийцу.",
  "Вестерн с перестрелками и скрытыми ролями.",
  "Российский аналог Dixit с уникальными артами.",
  "Русская рулетка, только с котятами.",
  "Развивайте свою цивилизацию и стройте чудеса света.",
];

List<List<String>> reviewList = [
  ["Классика!", "Играем всей семьей."],
  ["Лучшая стратегия.", "Нужно много думать."],
  ["Очень красивые карты."],
  ["Простые правила, глубокий геймплей."],
  ["Весело и быстро."],
  ["Очень атмосферно.", "Сложно выиграть."],
  ["Развивает воображение."],
  ["Отличный кооператив."],
  ["Идеально для вечеринок."],
  ["Город засыпает..."],
  ["Всегда ношу с собой."],
  ["Познавательно."],
  ["Для умных."],
  ["Много эмоций."],
  ["Увеличивает словарный запас."],
  ["Интересно разгадывать."],
  ["Для большой компании."],
  ["Картинки безумные."],
  ["Очень смешно."],
  ["Глубокая стратегия."],
];

List<String> titleList = [
  "Монополия",
  "Колонизаторы (Catan)",
  "Ticket to Ride",
  "Каркассон",
  "Манчкин",
  "Ужас Аркхэма",
  "Dixit",
  "Пандемия",
  "Кодовые имена",
  "Мафия",
  "Uno",
  "Эволюция",
  "Шахматы",
  "Дженга",
  "Scrabble",
  "Cluedo",
  "Бэнг!",
  "Имаджинариум",
  "Взрывные котята",
  "7 Чудес",
];

class _BoardGameCatalogScreenState extends State<BoardGameCatalogScreen> {
  List<BoardGame> allGames = List.generate(16, (index) {
    return BoardGame(
      id: index + 1,
      title: titleList[index],
      imageUrl: urlList[index],
      description: descriptionList[index],
      reviews: reviewList[index],
    );
  });

  List<BoardGame> filteredGames = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredGames = allGames;
    // Слушаем изменения авторизации для перерисовки иконки
    authState.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    authState.removeListener(_onAuthStateChanged);
    searchController.dispose();
    super.dispose();
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
    }
    setState(() {
      filteredGames = results;
    });
  }

  // Открыть кабинет или экран логина в зависимости от состояния
  void _openAccountLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            authState.isLoggedIn ? ProfileScreen() : LoginScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Бронирование игр"),
        actions: [
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
      body: filteredGames.isEmpty
          ? Center(child: Text("Игры не найдены"))
          : GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: filteredGames.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(game: game),
                      ),
                    );
                    setState(() {});
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
                            child: Image.network(
                              game.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                game.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                                onPressed: () {
                                  setState(() {
                                    game.isFavorite = !game.isFavorite;
                                  });
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
    );
  }
}
