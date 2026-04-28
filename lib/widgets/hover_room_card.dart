import 'package:flutter/material.dart';

const mainColor = Color(0xFFD39595);

class HoverRoomCard extends StatelessWidget {
  final String name;
  final double temp;
  final int humidity;
  final bool isUpdated;

  const HoverRoomCard({
    super.key,
    required this.name,
    required this.temp,
    required this.humidity,
    required this.isUpdated,
  });

  Color _getTempColor() {
    if (temp >= 30) return Colors.red;
    if (temp <= 18) return Colors.blue;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hover, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hover
                    ? mainColor
                    : (isUpdated
                          ? Colors.green.withOpacity(0.3)
                          : Colors.transparent),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                if (!isUpdated)
                  const Text(
                    'Очікування...',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  )
                else ...[
                  Text(
                    '${temp.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getTempColor(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Вологість: $humidity%',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.thermostat, color: mainColor, size: 18),
                      SizedBox(width: 6),
                      Icon(Icons.water_drop, color: mainColor, size: 18),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
