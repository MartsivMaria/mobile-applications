import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../services/local_user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final repo = LocalUserRepository();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  void showError(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Помилка",
          style: TextStyle(color: Color(0xFFD39595)),
        ),
        content: Text(text, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showError("Будь ласка, заповніть усі поля");
      return;
    }

    setState(() => isLoading = true);

    bool hasInternet = await _checkInternet();
    if (!hasInternet) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Помилка: Відсутнє підключення до інтернету!'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }

    final success = await repo.login(email, password);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showError("Неправильний логін або пароль");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFFD39595);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'RoomClimate Tracker',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomInput(hint: 'Email', controller: emailController),
                  const SizedBox(height: 12),

                  CustomInput(
                    hint: 'Password',
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  isLoading
                      ? const CircularProgressIndicator(color: mainColor)
                      : CustomButton(
                          text: 'Увійти',
                          color: mainColor,
                          onPressed: login,
                        ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Реєстрація',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
