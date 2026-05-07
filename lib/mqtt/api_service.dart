import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "http://192.168.0.105:5002/api";

  static Future<List<dynamic>> getRooms() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/rooms"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error loading data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Could not connect to server: $e");
    }
  }

  static Future<void> logRoomAction(String roomName, String action) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/action"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"room": roomName, "action": action}),
      );
    } catch (e) {
      print("Logging failed: $e");
    }
  }

  static Future<bool> addRoom(String roomName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/rooms/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": roomName,
          "temperature": 21.0,
          "humidity": 45.0,
        }),
      );

      if (response.statusCode == 201) {
        print("Кімната '$roomName' успішно додана на сервер");
        return true;
      } else {
        print("Помилка сервера: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Помилка з'єднання: $e");
      return false;
    }
  }

  static Future<void> updateRoomData(
    String roomName,
    double temp,
    int humidity,
  ) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/rooms/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": roomName,
          "temperature": temp,
          "humidity": humidity,
        }),
      );
    } catch (e) {
      print("Не вдалося оновити дані в БД: $e");
    }
  }
}
