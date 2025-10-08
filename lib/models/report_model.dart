import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Report {
  final String id;
  final String type;
  final String severity;
  final String address;
  final LatLng coords;
  final DateTime date;

  Report({
    required this.id,
    required this.type,
    required this.severity,
    required this.address,
    required this.coords,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        type: json["type"],
        severity: json["severity"],
        address: json["address"],
        coords: LatLng(json["coords"]["latitude"], json["coords"]["longitude"]),
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "severity": severity,
        "address": address,
        "date": date.toIso8601String(),
      };

  String toJsonString() => json.encode(toMap());

  Report copy() => Report(
        id: id,
        type: type,
        severity: severity,
        address: address,
        coords: coords,
        date: date,
      );

  String get formattedDate {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case "grave":
        return Colors.red;
      case "moderado":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
