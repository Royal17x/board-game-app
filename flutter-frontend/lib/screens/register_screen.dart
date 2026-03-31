import 'package:board_game_app/screens/profile_screen.dart';
import 'package:board_game_app/services/auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _confirmObcurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (username.isEmpty) {
      setState(() {
        _errorMessage = "Логин не может быть пустым";
      });
      return;
    }
    if (password.trim().isEmpty) {
      setState(() {
        _errorMessage = "Пароль не может быть пустым";
      });
      return;
    }
    if (confirmPassword.trim().isEmpty) {
      setState(() {
        _errorMessage = "Подтвердите пароль";
      });
      return;
    }
    if (username.length < 6) {
      setState(() {
        _errorMessage = "Слишком короткий логин";
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = "Слишком короткий пароль";
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Пароли не совпадают";
      });
      return;
    }
    final success = await authState.register(
      _usernameController.text,
      _passwordController.text,
    );
    if (success) {
      _errorMessage = null;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Регистрация")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, color: Colors.blueAccent),
              SizedBox(height: 32),
              Text(
                "Здравствуйте, пройдите регистрацию",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height: 8),
              Text(
                'Зарегистрируйтесь, чтобы пользоваться сервисом',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Логин",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Пароль",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _confirmObcurePassword,
                decoration: InputDecoration(
                  labelText: "Подтверждение пароля",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmObcurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmObcurePassword = !_confirmObcurePassword;
                      });
                    },
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Зарегистрироваться",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
