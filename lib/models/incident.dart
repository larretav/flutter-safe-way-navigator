import 'dart:convert';

Map<String, Incident> incidentFromJson(String str) => Map.from(json.decode(str))
    .map((k, v) => MapEntry<String, Incident>(k, Incident.fromJson(v)));

String incidentToJson(Map<String, Incident> data) => json.encode(
    Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())));

class Incident {
  String type; // Ej: "choque", "inundación", "embotellamiento"
  String location; // Ubicación exacta o calle
  String severity; // "baja", "media", "alta"
  String? description; // Texto opcional
  DateTime dateTime; // Fecha y hora del reporte
  bool active; // true si sigue activo, false si resuelto
  String? id; // Opcional (ID de BD)

  Incident({
    required this.type,
    required this.location,
    required this.severity,
    this.description,
    required this.dateTime,
    this.active = true,
    this.id,
  });

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        type: json["type"],
        location: json["location"],
        severity: json["severity"],
        description: json["description"],
        dateTime: DateTime.parse(json["dateTime"]),
        active: json["active"],
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "location": location,
        "severity": severity,
        "description": description,
        "dateTime": dateTime.toIso8601String(),
        "active": active,
        "id": id,
      };

  String toJsonString() => json.encode(toMap());

  Incident copyWith({
    String? type,
    String? location,
    String? severity,
    String? description,
    DateTime? dateTime,
    bool? active,
    String? id,
  }) {
    return Incident(
      type: type ?? this.type,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      active: active ?? this.active,
      id: id ?? this.id,
    );
  }
}
