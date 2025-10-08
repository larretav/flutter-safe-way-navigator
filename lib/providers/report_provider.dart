import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/report_model.dart';

class ReportProvider with ChangeNotifier {
  final List<Report> _reports = [
    Report(
      id: "1",
      type: "Accidente",
      severity: "Grave",
      address: "Blvd. Rosales y Serdán",
      coords: const LatLng(25.7969, -108.9954),
      date: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Report(
      id: "2",
      type: "Inundación",
      severity: "Moderado",
      address: "Av. Independencia",
      coords: const LatLng(25.7996, -109.0108),
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Report(
      id: "3",
      type: "Obras viales",
      severity: "Leve",
      address: "Calle Hidalgo",
      coords: const LatLng(25.8231, -108.9737),
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Report> get reports => List.unmodifiable(_reports);

  void addReport(Report report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void removeReport(String id) {
    _reports.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
