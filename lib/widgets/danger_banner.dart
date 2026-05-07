import 'package:flutter/material.dart';

class DangerBanner extends StatelessWidget {
  final List<String> rooms;
  const DangerBanner({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Увага! Небезпека у: ${rooms.join(', ')}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final Color mainColor;
  const StatusCard({super.key, required this.mainColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Моніторинг АКТИВНИЙ',
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Icon(Icons.cloud_sync, size: 60, color: mainColor),
          const SizedBox(height: 8),
          const Text(
            'Дані синхронізуються з сервером Python та MQTT',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
