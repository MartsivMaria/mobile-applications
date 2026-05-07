class UserModel {
  final String fullName;
  final String email;
  final String password;

  final List<String> rooms;

  final double? minTempAlert;
  final double? maxTempAlert;
  final double? minHumidityAlert;
  final double? maxHumidityAlert;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.rooms = const [],
    this.minTempAlert,
    this.maxTempAlert,
    this.minHumidityAlert,
    this.maxHumidityAlert,
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
    List<String>? rooms,
    double? minTempAlert,
    double? maxTempAlert,
    double? minHumidityAlert,
    double? maxHumidityAlert,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      rooms: rooms ?? this.rooms,
      minTempAlert: minTempAlert ?? this.minTempAlert,
      maxTempAlert: maxTempAlert ?? this.maxTempAlert,
      minHumidityAlert: minHumidityAlert ?? this.minHumidityAlert,
      maxHumidityAlert: maxHumidityAlert ?? this.maxHumidityAlert,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'rooms': rooms,
    'minTempAlert': minTempAlert,
    'maxTempAlert': maxTempAlert,
    'minHumidityAlert': minHumidityAlert,
    'maxHumidityAlert': maxHumidityAlert,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    rooms: json['rooms'] != null ? List<String>.from(json['rooms']) : [],

    minTempAlert: json['minTempAlert'] != null
        ? (json['minTempAlert'] as num).toDouble()
        : null,
    maxTempAlert: json['maxTempAlert'] != null
        ? (json['maxTempAlert'] as num).toDouble()
        : null,
    minHumidityAlert: json['minHumidityAlert'] != null
        ? (json['minHumidityAlert'] as num).toDouble()
        : null,
    maxHumidityAlert: json['maxHumidityAlert'] != null
        ? (json['maxHumidityAlert'] as num).toDouble()
        : null,
  );
}
