import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(BoardGamesApp());
}

class BoardGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Бронирование Настольных Игр",
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: BoardGameCatalogScreen(),
    );
  }
}
