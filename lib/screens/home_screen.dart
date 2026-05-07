import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_smart_thermometer_plugin/my_smart_thermometer_plugin.dart';

import '../logic/home/home_cubit.dart';
import '../logic/home/home_state.dart';
import '../widgets/danger_banner.dart';
import '../widgets/hover_room_card.dart';

const mainColor = Color(0xFFD39595);

bool _isFlashOn = false;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<HomeCubit>()..init(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _handleFlashlight(BuildContext context) async {
    try {
      _isFlashOn = !_isFlashOn;
      await MySmartThermometerPlugin.toggleLight(_isFlashOn);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFlashOn
                  ? 'Секретний режим: ЛІХТАР УВІМКНЕНО'
                  : 'Секретний режим: ЛІХТАР ВИМКНЕНО',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: mainColor,
          ),
        );
      }
    } on PlatformException catch (e) {
      _isFlashOn = !_isFlashOn;

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Попередження'),
            content: Text(e.message ?? 'Функціонал не підтримується'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: mainColor)),
          );
        }
        if (state is HomeError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        if (state is! HomeLoaded) return const SizedBox();

        final user = state.user;
        final liveData = state.liveData;
        final isOffline = state.isOffline;
        final roomNames = user.rooms ?? [];

        final dangerousRooms = liveData.entries
            .where(
              (e) =>
                  (e.value['temp'] ?? 0) >= 30 || (e.value['temp'] ?? 0) <= 18,
            )
            .map((e) => e.key)
            .toList();

        final width = MediaQuery.of(context).size.width;
        final crossAxisCount = width < 600 ? 2 : 3;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onLongPress: () => _handleFlashlight(context),
              child: const Text('RoomClimate Tracker'),
            ),
            backgroundColor: Colors.black,
            elevation: 0,
            actions: [
              Icon(
                isOffline ? Icons.wifi_off : Icons.wifi,
                color: isOffline ? Colors.orange : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.person, color: mainColor),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/profile');
                  if (context.mounted) {
                    context.read<HomeCubit>().init();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Text(
                    'Офлайн режим: перевірте підключення',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RefreshIndicator(
                    onRefresh: () async => context.read<HomeCubit>().init(),
                    color: mainColor,
                    child: Column(
                      children: [
                        if (dangerousRooms.isNotEmpty)
                          DangerBanner(rooms: dangerousRooms),

                        Expanded(
                          child: roomNames.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Додайте кімнати у профілі,\nщоб почати моніторинг.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  itemCount: roomNames.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: width < 400
                                            ? 1.1
                                            : 1.3,
                                      ),
                                  itemBuilder: (context, index) {
                                    final name = roomNames[index];
                                    final data = liveData[name];
                                    return GestureDetector(
                                      onTap: () => context
                                          .read<HomeCubit>()
                                          .logAction("Перегляд кімнати", name),
                                      child: HoverRoomCard(
                                        name: name,
                                        temp: (data?['temp'] ?? 0.0).toDouble(),
                                        humidity: (data?['humidity'] ?? 0)
                                            .toInt(),
                                        isUpdated: data != null && !isOffline,
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Моніторинг АКТИВНИЙ',
                                style: TextStyle(
                                  color: mainColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              Icon(
                                Icons.cloud_sync,
                                size: 60,
                                color: mainColor,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Графік температури та вологості',
                                style: TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
