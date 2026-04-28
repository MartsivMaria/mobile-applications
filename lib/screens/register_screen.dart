import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../models/user_model.dart';
import '../utils/validation.dart';

class RegisterScreen extends StatelessWidget {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RegisterScreen({super.key});

  void showError(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Помилка',
          style: TextStyle(color: Color(0xFFD39595)),
        ),
        content: Text(text, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
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
          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/login');
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
                      'Створити акаунт',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomInput(
                      hint: 'Full Name',
                      controller: fullNameController,
                    ),
                    const SizedBox(height: 24),

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

                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const CircularProgressIndicator(
                            color: mainColor,
                          );
                        }
                        return CustomButton(
                          text: 'Зареєструватись',
                          color: mainColor,
                          onPressed: () {
                            final name = fullNameController.text.trim();
                            final email = emailController.text.trim();
                            final password = passwordController.text;
                            final confirmPassword =
                                confirmPasswordController.text;

                            final nameError = AppValidators.validateFullName(
                              name,
                            );
                            if (nameError != null) {
                              showError(context, nameError);
                              return;
                            }

                            final emailError = AppValidators.validateEmail(
                              email,
                            );
                            if (emailError != null) {
                              showError(context, emailError);
                              return;
                            }

                            final passwordError =
                                AppValidators.validatePassword(password);
                            if (passwordError != null) {
                              showError(context, passwordError);
                              return;
                            }

                            final confirmError = AppValidators.confirmPassword(
                              confirmPassword,
                              password,
                            );
                            if (confirmError != null) {
                              showError(context, confirmError);
                              return;
                            }

                            final user = UserModel(
                              fullName: name,
                              email: email,
                              password: password,
                              rooms: [],
                            );
                            context.read<AuthCubit>().register(user);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
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
      ),
    );
  }
}
