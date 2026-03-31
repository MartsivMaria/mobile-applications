import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../services/local_user_repository.dart';
import '../models/user_model.dart';
import '../utils/validation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final repo = LocalUserRepository();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showError(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Помилка'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void register() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final nameError = AppValidators.validateFullName(name);
    if (nameError != null) {
      showError(nameError);
      return;
    }

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) {
      showError(emailError);
      return;
    }

    final passwordError = AppValidators.validatePassword(password);
    if (passwordError != null) {
      showError(passwordError);
      return;
    }

    final confirmError = AppValidators.confirmPassword(
      confirmPassword,
      password,
    );
    if (confirmError != null) {
      showError(confirmError);
      return;
    }

    final user = UserModel(fullName: name, email: email, password: password);

    await repo.register(user);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFFD39595);

    return Scaffold(
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
                    'Створити акаунт',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomInput(hint: 'Імʼя', controller: fullNameController),
                  const SizedBox(height: 12),

                  CustomInput(hint: 'Email', controller: emailController),
                  const SizedBox(height: 12),

                  CustomInput(
                    hint: 'Password',
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  CustomInput(
                    hint: 'Confirm Password',
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  CustomButton(
                    text: 'Зареєструватись',
                    color: mainColor,
                    onPressed: register,
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      'У мене вже є акаунт',
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
