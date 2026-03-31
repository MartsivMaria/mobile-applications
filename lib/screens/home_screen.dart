import 'package:flutter/material.dart';
import 'dart:math';
import '../services/local_user_repository.dart';
import '../models/user_model.dart';

const mainColor = Color(0xFFD39595);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = LocalUserRepository();
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await repo.getUser();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: mainColor)),
      );
    }

    final List<String> roomNames = currentUser?.rooms ?? [];
    final random = Random();

    final roomsData = roomNames.map((name) {
      return {
        'name': name,
        'temp': 15 + random.nextInt(21),
        'humidity': 30 + random.nextInt(51),
      };
    }).toList();

    final dangerousRooms = roomsData
        .where((r) => (r['temp'] as int) >= 30 || (r['temp'] as int) <= 18)
        .map((r) => r['name'] as String)
        .toList();

    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width < 600 ? 2 : 3;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 ОТ УБРАЛИ СТРІЛКУ
        title: const Text('RoomClimate Tracker'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: mainColor),
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
              _loadData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (dangerousRooms.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Увага! Небезпека у: ${dangerousRooms.join(', ')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            Expanded(
              child: roomNames.isEmpty
                  ? const Center(
                      child: Text(
                        'У вас поки немає кімнат.\nДодайте їх у профілі!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      itemCount: roomsData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: width < 400 ? 1.1 : 1.3,
                      ),
                      itemBuilder: (context, index) {
                        final room = roomsData[index];
                        return HoverRoomCard(
                          name: room['name'] as String,
                          temp: room['temp'] as int,
                          humidity: room['humidity'] as int,
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
              child: Column(
                children: const [
                  Text(
                    'Історія останніх вимірювань',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Icon(Icons.show_chart, size: 60, color: mainColor),
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
    );
  }
}

class HoverRoomCard extends StatefulWidget {
  final String name;
  final int temp;
  final int humidity;

  const HoverRoomCard({
    super.key,
    required this.name,
    required this.temp,
    required this.humidity,
  });

  @override
  State<HoverRoomCard> createState() => _HoverRoomCardState();
}

class _HoverRoomCardState extends State<HoverRoomCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? mainColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                'Температура: ${widget.temp}°C',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.temp >= 30
                      ? Colors.red
                      : widget.temp <= 18
                      ? Colors.blue
                      : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                'Вологість: ${widget.humidity}%',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.thermostat, color: mainColor, size: 18),
                SizedBox(width: 6),
                Icon(Icons.water_drop, color: mainColor, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
