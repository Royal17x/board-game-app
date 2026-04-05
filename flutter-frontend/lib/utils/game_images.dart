const Map<int, String> gameImageAssets = {
  1: 'assets/images/monopoly.jpg',
  2: 'assets/images/catan.jpg',
  3: 'assets/images/ticket_to_ride.jpg',
  4: 'assets/images/carcassonne.jpg',
  5: 'assets/images/munchkin.jpg',
  6: 'assets/images/arkham.jpg',
  7: 'assets/images/dixit.jpg',
  8: 'assets/images/pandemic.jpg',
  9: 'assets/images/codenames.jpg',
  10: 'assets/images/mafia.jpg',
  11: 'assets/images/uno.jpg',
  12: 'assets/images/evolution.jpg',
  13: 'assets/images/chess.jpg',
  14: 'assets/images/jenga.jpg',
  15: 'assets/images/scrabble.jpg',
  16: 'assets/images/cluedo.jpg',
};

String getGameImage(int gameId) {
  return gameImageAssets[gameId] ?? 'assets/images/chess.jpg';
}
