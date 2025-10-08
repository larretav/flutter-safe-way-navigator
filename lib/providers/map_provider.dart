import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController mapController;

  LatLng? _selectedLocation;
  String? _address;

  LatLng? get selectedLocation => _selectedLocation;
  String? get address => _address;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> updateCoords(LatLng newLocation) async {
    _selectedLocation = newLocation;
    notifyListeners();
  }

  Future<void> updateLocation(LatLng? newLocation) async {
    if (newLocation == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        newLocation.latitude,
        newLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.reversed.last;
        _address =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      } else {
        _address =
            "${newLocation.latitude.toStringAsFixed(5)}, ${newLocation.longitude.toStringAsFixed(5)}";
      }
    } catch (e) {
      _address = "Dirección no disponible";
    }
    
    notifyListeners();
  }
}
