import 'package:flutter/material.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:board_game_app/widgets/inforow.dart';
import 'package:board_game_app/main.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _loginDate = _formattedNow();
  bool _darkMode = false;

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
    final displayName = user?.username ?? 'Пользователь';
    final isAdmin = user?.isAdmin ?? false;

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
            // +1 чип с ролью рядом с "Активен"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text("Активен"),
                  avatar: Icon(Icons.circle, size: 12, color: Colors.green),
                  backgroundColor: Colors.green.shade50,
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text(isAdmin ? "Администратор" : "Пользователь"),
                  avatar: Icon(
                    isAdmin ? Icons.shield : Icons.person,
                    size: 14,
                    color: isAdmin ? Colors.orange : Colors.indigo,
                  ),
                  backgroundColor: isAdmin
                      ? Colors.orange.shade50
                      : Colors.indigo.shade50,
                ),
              ],
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
                    Divider(),
                    // +1 строка InfoRow с ролью
                    InfoRow(
                      icon: isAdmin ? Icons.shield : Icons.person_outline,
                      label: "Роль",
                      value: isAdmin ? "Администратор" : "Пользователь",
                      valueColor: isAdmin ? Colors.orange : Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dark_mode, color: Colors.indigo, size: 22),
                        SizedBox(width: 12),
                        Text(
                          "Темная тема",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: themeNotifier.value == ThemeMode.dark,
                      activeColor: Colors.indigo,
                      onChanged: (val) {
                        themeNotifier.value = val
                            ? ThemeMode.dark
                            : ThemeMode.light;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
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
