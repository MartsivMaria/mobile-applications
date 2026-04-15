import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/local_user_repository.dart';
import '../models/user_model.dart';
import '../mqtt/mqtt_service.dart';

const mainColor = Color(0xFFD39595);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = LocalUserRepository();
  final MqttService _mqttService = MqttService();

  UserModel? currentUser;
  bool isLoading = true;
  Map<String, Map<String, dynamic>> liveData = {};

  late StreamSubscription<List<ConnectivityResult>> _networkSubscription;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupMqtt();
    _initNetworkListener();
  }

  void _initNetworkListener() {
    _networkSubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final bool currentlyOffline = result.contains(ConnectivityResult.none);

      if (mounted) {
        setState(() {
          isOffline = currentlyOffline;
        });

        if (currentlyOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Зв'язок втрачено. Дані можуть бути застарілими."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          _mqttService.connect();
        }
      }
    });
  }

  void _setupMqtt() {
    _mqttService.connect();
    _mqttService.addListener(() {
      if (mounted) {
        setState(() {
          liveData = Map.from(_mqttService.liveData);
        });
      }
    });
  }

  Future<void> _loadData() async {
    final user = await repo.getUser();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _networkSubscription.cancel();
    _mqttService.removeListener(() {});
    _mqttService.disconnect();
    super.dispose();
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

    final dangerousRooms = liveData.entries
        .where(
          (entry) => entry.value['temp'] >= 30 || entry.value['temp'] <= 18,
        )
        .map((entry) => entry.key)
        .toList();

    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width < 600 ? 2 : 3;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('RoomClimate Tracker'),
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
              _loadData();
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
                                  childAspectRatio: width < 400 ? 1.1 : 1.3,
                                ),
                            itemBuilder: (context, index) {
                              final name = roomNames[index];
                              final data = liveData[name];

                              return HoverRoomCard(
                                name: name,
                                temp: data?['temp'] ?? 0.0,
                                humidity: data?['humidity'] ?? 0,
                                isUpdated: data != null && !isOffline,
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
                          'Дані з датчиків MQTT відображаються в реальному часі',
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
        ],
      ),
    );
  }
}

class HoverRoomCard extends StatefulWidget {
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
            color: isHovered
                ? mainColor
                : (widget.isUpdated
                      ? Colors.green.withOpacity(0.3)
                      : Colors.transparent),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (!widget.isUpdated)
              const Text(
                'Очікування...',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              )
            else ...[
              Text(
                '${widget.temp.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.temp >= 30
                      ? Colors.red
                      : (widget.temp <= 18 ? Colors.blue : Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Вологість: ${widget.humidity}%',
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
      ),
    );
  }
}
