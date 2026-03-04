import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ThermometerScreen(),
    );
  }
}

class ThermometerScreen extends StatefulWidget {
  const ThermometerScreen({super.key});

  @override
  State<ThermometerScreen> createState() => _ThermometerScreenState();
}

class _ThermometerScreenState extends State<ThermometerScreen>
    with SingleTickerProviderStateMixin {
  double temperature = 0;
  String message = "Enter the temperature";

  final TextEditingController controller = TextEditingController();

  void updateTemperature() {
    String input = controller.text;

    if (input.toLowerCase() == "reset") {
      setState(() {
        temperature = 0;
        message = "Reset!";
      });
      return;
    }

    double? value = double.tryParse(input);

    if (value != null) {
      setState(() {
        temperature = value;

        if (temperature > 30) {
          message = "Hot!🔥";
        } else if (temperature < 10) {
          message = "Cold!❄️";
        } else {
          message = "Ideal temperature!";
        }
      });
    } else {
      setState(() {
        message = "Enter a number or Reset";
      });
    }
  }

  Color getThermometerColor() {
    if (temperature > 30) return Colors.red;
    if (temperature < 10) return Colors.blue;
    return Colors.green;
  }

  double getThermometerHeight() {
    double minTemp = -10;
    double maxTemp = 40;
    double height = ((temperature - minTemp) / (maxTemp - minTemp)) * 200;
    if (height < 0) height = 0;
    if (height > 200) height = 200;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Home Thermometer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Temperature: $temperature °C",
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 40,
                        height: getThermometerHeight(),
                        decoration: BoxDecoration(
                          color: getThermometerColor(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter temperature",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateTemperature,
              child: const Text("Update"),
            ),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
