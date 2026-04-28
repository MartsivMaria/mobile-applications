import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

import 'services/auth_service.dart';
import 'services/local_user_repository.dart';
import 'mqtt/mqtt_service.dart';

import 'logic/auth/auth_cubit.dart';
import 'logic/home/home_cubit.dart';
import 'logic/profile/profile_cubit.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<LocalUserRepository>(LocalUserRepository());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<MqttService>(MqttService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setup();

  final authService = getIt<AuthService>();
  final bool loggedIn = await authService.isLoggedIn();

  final String startRoute = loggedIn ? '/home' : '/login';

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(getIt<LocalUserRepository>()),
        ),

        BlocProvider(
          create: (_) =>
              HomeCubit(getIt<LocalUserRepository>(), getIt<MqttService>()),
        ),
        BlocProvider(
          create: (context) =>
              UserCubit(getIt<LocalUserRepository>())..loadUser(),
        ),
        /*
        BlocProvider(
          create: (context) => UserCubit(getIt<AuthService>())..loadUser(),
        ),
        */
      ],
      child: MyApp(initialRoute: startRoute),
    ),
  );
}

const Color mainColor = Color(0xFFD39595);

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomClimate Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
