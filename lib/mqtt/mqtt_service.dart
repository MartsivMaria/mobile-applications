import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:flutter/material.dart';

class MqttService extends ChangeNotifier {
  MqttBrowserClient? client;

  Map<String, Map<String, dynamic>> liveData = {};

  Future<bool> connect() async {
    client = MqttBrowserClient(
      'ws://test.mosquitto.org/mqtt',
      'martsiv_web_client_${DateTime.now().millisecondsSinceEpoch}',
    );

    client!.port = 8080;
    client!.keepAlivePeriod = 20;

    client!.websocketProtocols = ['mqtt'];

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client!.clientIdentifier)
        .startClean();
    client!.connectionMessage = connMessage;

    try {
      debugPrint('⏳ Підключення до MQTT (WebSockets)...');
      await client!.connect();

      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint('MQTT підключено!');
        _setupSubscriptions();
        return true;
      }
    } catch (e) {
      debugPrint('Помилка підключення: $e');
      client!.disconnect();
    }
    return false;
  }

  void _setupSubscriptions() {
    const String topicPath = 'room/climate/data/#';
    client!.subscribe(topicPath, MqttQos.atMostOnce);

    final Map<String, String> reverseTranslation = {
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

      final String englishKey = topic.split('/').last.toLowerCase();

      final String roomName = reverseTranslation[englishKey] ?? englishKey;

      try {
        final List<String> parts = payload.split(',');
        if (parts.length == 2) {
          liveData[roomName] = {
            'temp': double.parse(parts[0]),
            'humidity': int.parse(parts[1]),
          };
          notifyListeners();
          debugPrint('Дані отримано [$roomName]: $payload');
        }
      } catch (e) {
        debugPrint('Помилка парсингу: $e');
      }
    });
  }

  void disconnect() {
    client?.disconnect();
    debugPrint('MQTT відключено');
  }
}
