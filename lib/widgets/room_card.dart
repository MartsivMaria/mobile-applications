import 'package:flutter/material.dart';

const mainColor = Color(0xFFD39595);

class RoomCard extends StatefulWidget {
  final String room;
  final int temp;
  final int humidity;

  const RoomCard({
    super.key,
    required this.room,
    required this.temp,
    required this.humidity,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool isHovered = false;

  Color getTempColor() {
    if (widget.temp >= 30) return Colors.red;
    if (widget.temp <= 18) return Colors.blue;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? mainColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.room,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thermostat, color: mainColor),
                const SizedBox(width: 6),
                Text(
                  '${widget.temp}°C',
                  style: TextStyle(color: getTempColor(), fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.water_drop, color: mainColor),
                SizedBox(width: 6),
              ],
            ),

            Text(
              '${widget.humidity}%',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
