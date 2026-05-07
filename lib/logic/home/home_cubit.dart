import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'home_state.dart';
import '../../services/local_user_repository.dart';
import '../../models/user_model.dart';
import '../../mqtt/mqtt_service.dart';
import '../../mqtt/api_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final LocalUserRepository repo;
  final MqttService mqtt;

  static const String serverIp = "192.168.0.4";

  StreamSubscription? networkSubscription;

  UserModel? currentUser;
  Map<String, Map<String, dynamic>> liveData = {};
  bool isOffline = false;

  HomeCubit(this.repo, this.mqtt) : super(HomeInitial());

  Future<void> init() async {
    emit(HomeLoading());

    await _loadUser();
    _setupMqtt();
    _initNetworkListener();
    await _refreshFromApi();

    emit(
      HomeLoaded(user: currentUser!, liveData: liveData, isOffline: isOffline),
    );
  }

  Future<void> _loadUser() async {
    currentUser = await repo.getUser();
  }

  Future<void> _refreshFromApi() async {
    try {
      final response = await http.get(
        Uri.parse("http://$serverIp:5002/api/rooms"),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        for (var room in data) {
          liveData[room['name']] = {
            'temp': room['temperature'],
            'humidity': room['humidity'],
          };
        }
      }
    } catch (_) {}

    _emitLoaded();
  }

  void _setupMqtt() {
    mqtt.connect();

    mqtt.addListener(() {
      liveData = Map.from(mqtt.liveData);

      mqtt.liveData.forEach((name, data) {
        ApiService.updateRoomData(
          name,
          (data['temp'] ?? 0.0).toDouble(),
          (data['humidity'] ?? 0).toInt(),
        );
      });

      _emitLoaded();
    });
  }

  void _initNetworkListener() {
    networkSubscription = Connectivity().onConnectivityChanged.listen((result) {
      isOffline = result.contains(ConnectivityResult.none);

      if (!isOffline) {
        mqtt.connect();
        _refreshFromApi();
      }

      _emitLoaded();
    });
  }

  Future<void> logAction(String action, String room) async {
    try {
      await http.post(
        Uri.parse("http://$serverIp:5002/api/action"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": action, "room": room}),
      );
    } catch (_) {}
  }

  void _emitLoaded() {
    if (currentUser == null) return;

    emit(
      HomeLoaded(user: currentUser!, liveData: liveData, isOffline: isOffline),
    );
  }

  @override
  Future<void> close() {
    networkSubscription?.cancel();
    mqtt.disconnect();
    return super.close();
  }
}
