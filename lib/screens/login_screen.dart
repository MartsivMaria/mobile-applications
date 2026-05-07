import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  void showError(BuildContext context, String text) {
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

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFFD39595);

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            showError(context, state.error);
          }
        },
        child: Center(
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

                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const CircularProgressIndicator(
                            color: mainColor,
                          );
                        }
                        return CustomButton(
                          text: 'Увійти',
                          color: mainColor,
                          onPressed: () {
                            context.read<AuthCubit>().login(
                              emailController.text.trim(),
                              passwordController.text,
                            );
                          },
                        );
                      },
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
      ),
    );
  }
}
