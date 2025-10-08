import 'package:flutter/material.dart';
import '../models/report_model.dart';

class ReportProvider with ChangeNotifier {
  final List<Report> _reports = [
    Report(
      id: "1",
      type: "Accidente",
      severity: "Grave",
      address: "Blvd. Rosales y Serdán",
      date: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Report(
      id: "2",
      type: "Inundación",
      severity: "Moderado",
      address: "Av. Independencia",
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Report(
      id: "3",
      type: "Obras viales",
      severity: "Leve",
      address: "Calle Hidalgo",
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
