import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:safe_way_navigator/models/incident_model.dart';


enum ReportSeverity { mild, moderate, severe }

typedef MenuEntry = DropdownMenuEntry<String>;
const List<String> incidentTypes = [
  "Accidente",
  "Embotellamiento",
  "Inundación",
  "Obra/Construcción",
  "Bache"
];


class IncidentProvider with ChangeNotifier {

  String incidentType = incidentTypes.first;
  String location = "Blvd. Francisco Agraz, Tepeca, 81248 Los Mochis, Sin.";
  
  ReportSeverity severity = ReportSeverity.mild;
  final TextEditingController descriptionController = TextEditingController();

  static final List<MenuEntry> incidentMenuEntries = UnmodifiableListView(
    incidentTypes.map((String name) => MenuEntry(value: name, label: name)),
  );

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<Incident> _incidents = [];
  List<Incident> get incidents => _incidents;

  void addIncident(Incident incident) {
    _incidents.add(incident);
    notifyListeners();
  }

  bool isValidForm() {
    // print(formKey.currentState?.validate());
    return formKey.currentState?.validate() ?? false;
  }
}
