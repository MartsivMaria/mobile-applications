import paho.mqtt.client as mqtt
import time
import random

BROKER = "broker.hivemq.com" 
PORT = 1883

client = mqtt.Client()

try:
    client.connect(BROKER, PORT, 60)
    client.loop_start()
    print(f"Емулятор підключився до {BROKER}")
except Exception as e:
    print(f"Помилка підключення: {e}")
    exit()

rooms = {
    "kitchen": {"name": "кухня", "temp": 22.0, "hum": 45},
    "bedroom": {"name": "спальня", "temp": 20.0, "hum": 50},
    "livingroom": {"name": "вітальня", "temp": 21.5, "hum": 48}
}

print(" Початок емуляції датчиків...")

try:
    while True:
        for key, data in rooms.items():
            data["temp"] += round(random.uniform(-0.5, 0.5), 1)
            data["hum"] += random.randint(-1, 1)

            data["temp"] = max(15.0, min(data["temp"], 35.0))
            data["hum"] = max(20, min(data["hum"], 90))

            payload = f"{data['temp']:.1f},{data['hum']}"
            
            topic = f"room/climate/data/{key}"
            
            client.publish(topic, payload)
            
            print(f"Відправлено: {data['name']} ({topic}) -> {payload}")

        print("-" * 30)
        time.sleep(5)
except KeyboardInterrupt:
    print("\nЕмуляцію зупинено")
    client.loop_stop()
    client.disconnect()