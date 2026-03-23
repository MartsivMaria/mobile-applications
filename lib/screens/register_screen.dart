import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      color: Color(0xFFD39595),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const CustomInput(hint: 'Full name'),
                  const SizedBox(height: 12),

                  const CustomInput(hint: 'Email'),
                  const SizedBox(height: 12),

                  const CustomInput(hint: 'Password'),
                  const SizedBox(height: 12),

                  const CustomInput(hint: 'Confirm Password'),
                  const SizedBox(height: 20),

                  CustomButton(
                    text: 'Зареєструватись',
                    color: const Color(0xFFD39595),
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text('У мене вже є акаунт'),
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
