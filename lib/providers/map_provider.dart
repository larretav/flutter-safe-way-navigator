import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController mapController;

  LatLng? _selectedLocation;

  LatLng? get selectedLocation => _selectedLocation;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateLocation(LatLng newLocation) {
    _selectedLocation = newLocation;
    notifyListeners(); // 🔥 Notifica a los widgets que dependan de esta info
  }
}
