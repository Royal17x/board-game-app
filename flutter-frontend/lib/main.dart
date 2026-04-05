import 'package:board_game_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
void main() {
  runApp(BoardGamesApp());
}

class BoardGamesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Бронирование Настольных Игр",
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          home: SplashScreen(),
        );
      },
    );
  }
}
