import 'package:flutter/material.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:board_game_app/widgets/inforow.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Дата входа (фиксируется при открытии экрана)
  final String _loginDate = _formattedNow();

  static String _formattedNow() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return "$day.$month.$year  $hour:$minute";
  }

  void _logout() {
    authState.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    String displayName;
    if (user!=null){
      displayName = user.username;
    } else{
      displayName = 'Пользователь';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Личный кабинет"),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.red),
            label: Text("Выйти", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Ава
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              displayName,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Chip(
              label: Text("Активен"),
              avatar: Icon(Icons.circle, size: 12, color: Colors.green),
              backgroundColor: Colors.green.shade50,
            ),
            SizedBox(height: 32),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.person,
                      label: "Логин",
                      value: displayName,
                    ),
                    Divider(),
                    InfoRow(
                      icon: Icons.access_time,
                      label: "Вход выполнен",
                      value: _loginDate,
                    ),
                    Divider(),
                    InfoRow(
                      icon: Icons.verified_user,
                      label: "Статус",
                      value: "Авторизован",
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Кнопка выхода
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  "Выйти из кабинета",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
