import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';

class MqttService extends ChangeNotifier {
  MqttServerClient? client;

  Map<String, Map<String, dynamic>> liveData = {};

  Future<bool> connect() async {
    client = MqttServerClient(
      'mqtt-dashboard.com',
      'martsiv_mobile_${DateTime.now().millisecondsSinceEpoch}',
    );

    client!.port = 1883;
    client!.keepAlivePeriod = 60;
    client!.logging(on: true);

    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client!.clientIdentifier)
        .startClean();

    client!.connectionMessage = connMessage;

    try {
      debugPrint('Підключення до MQTT...');
      await client!.connect();

      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint(' Підключено!');
        _setupSubscriptions();
        return true;
      } else {
        debugPrint(' Не підключено');
        client!.disconnect();
      }
    } catch (e) {
      debugPrint(' Помилка: $e');
      client!.disconnect();
    }

    return false;
  }

  void onConnected() {
    debugPrint(' MQTT Connected');
  }

  void onDisconnected() {
    debugPrint(' MQTT Disconnected');
  }

  void _setupSubscriptions() {
    const String topicPath = 'room/climate/data/#';
    client!.subscribe(topicPath, MqttQos.atMostOnce);

    final Map<String, String> rooms = {
      'kitchen': 'Кухня',
      'bedroom': 'Спальня',
      'livingroom': 'Вітальня',
    };

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMess = messages[0].payload as MqttPublishMessage;

      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      final topic = messages[0].topic;

      final String key = topic.split('/').last.toLowerCase();
      final String roomName = rooms[key] ?? key;

      try {
        final parts = payload.split(',');

        if (parts.length == 2) {
          liveData[roomName] = {
            'temp': double.parse(parts[0]),
            'humidity': int.parse(parts[1]),
          };

          notifyListeners();

          debugPrint(' [$roomName]: $payload');
        }
      } catch (e) {
        debugPrint(' Помилка даних: $payload');
      }
    });
  }

  void disconnect() {
    client?.disconnect();
    debugPrint(' MQTT відключено');
  }
}
