import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    'RoomClimate Tracker',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD39595),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const CustomInput(hint: 'Email'),
                  const SizedBox(height: 12),

                  const CustomInput(hint: 'Password'),
                  const SizedBox(height: 20),

                  CustomButton(
                    text: 'Увійти',
                    color: const Color(0xFFD39595),
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Реєстрація'),
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
