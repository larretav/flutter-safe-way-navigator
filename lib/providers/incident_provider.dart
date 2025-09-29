import 'package:flutter/material.dart';
import 'package:safe_way_navigator/models/incident.dart';

class IncidentProvider with ChangeNotifier {
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
