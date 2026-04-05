import 'package:flutter/material.dart';
import 'package:board_game_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthState extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('http://192.168.0.26:8080/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        notifyListeners();
        return true;
      } else {
        if (response.body.isEmpty) {
          return false;
        }
        final Map<String, dynamic> error = jsonDecode(response.body);
        print('Ошибка логина: ${error['error']}');
        return false;
      }
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) return false;
    final url = Uri.parse('http://192.168.0.26:8080/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        if (response.body.isEmpty) {
          return false;
        }
        final Map<String, dynamic> data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        if (_currentUser == null) {
          return false;
        }
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        print('Ошибка регистрации: ${error['error']}');
        return false;
      }
    } catch (e) {
      print("network error");
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

final authState = AuthState();
