import 'package:flutter/material.dart';

const mainColor = Color(0xFFD39595);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = [
      {'name': 'Кухня', 'temp': 28, 'humidity': 55},
      {'name': 'Спальня', 'temp': 21, 'humidity': 40},
      {'name': 'Вітальня', 'temp': 30, 'humidity': 60},
      {'name': 'Дитяча', 'temp': 19, 'humidity': 50},
    ];

    final dangerousRooms = rooms
        .where((r) => (r['temp'] as int) >= 30 || (r['temp'] as int) <= 18)
        .map((r) => r['name'])
        .toList();

    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = width < 600 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoomClimate Tracker'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: mainColor),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
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
                  'Увага! Небезпечний рівень температури: ${dangerousRooms.join(', ')}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),

            Expanded(
              child: GridView.builder(
                itemCount: rooms.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: width < 400 ? 1.1 : 1.3,
                ),
                itemBuilder: (context, index) {
                  final room = rooms[index];
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
