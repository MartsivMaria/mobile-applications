from flask import Flask, jsonify, request
import sqlite3
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 

def get_db_connection():
    conn = sqlite3.connect('climate.db')
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    conn.execute('''
        CREATE TABLE IF NOT EXISTS rooms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            temperature REAL NOT NULL,
            humidity REAL NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

@app.route('/api/rooms', methods=['GET'])
def get_rooms():
    conn = get_db_connection()
    rows = conn.execute('SELECT * FROM rooms').fetchall()
    conn.close()
    return jsonify([dict(row) for row in rows])

@app.route('/api/rooms/add', methods=['POST'])
def add_room():
    data = request.json
    name = data.get('name')
    temp = data.get('temperature', 21.0)
    hum = data.get('humidity', 45.0)

    if not name:
        return jsonify({"status": "error", "message": "Назва обов'язкова"}), 400

    try:
        conn = get_db_connection()
        conn.execute('INSERT INTO rooms (name, temperature, humidity) VALUES (?, ?, ?)',
                     (name, temp, hum))
        conn.commit()
        conn.close()
        print(f" СТВОРЕНО НОВУ КІМНАТУ: {name} +++")
        return jsonify({"status": "success"}), 201
    except sqlite3.IntegrityError:
        return jsonify({"status": "error", "message": "Кімната з такою назвою вже є"}), 400

@app.route('/api/rooms/update', methods=['POST'])
def update_room_data():
    data = request.json
    name = data.get('name')
    temp = data.get('temperature')
    hum = data.get('humidity')

    conn = get_db_connection()
    conn.execute('UPDATE rooms SET temperature = ?, humidity = ? WHERE name = ?',
                 (temp, hum, name))
    conn.commit()
    conn.close()
    return jsonify({"status": "updated"}), 200

@app.route('/api/action', methods=['POST', 'OPTIONS'])
def log_action():
    if request.method == 'OPTIONS': return '', 200
    data = request.json
    action = data.get('action', 'Unknown')
    room = data.get('room', 'General')
    print(f"--- [LOG] ДІЯ: {action} --- КІМНАТА: {room} ---")
    return jsonify({"status": "success"}), 200

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5002, debug=True)