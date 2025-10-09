import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:safe_way_navigator/models/location_model.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController mapController;
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  LatLng? _selectedLocation;
  String? _currentAddress;

  LocationPlace? _origin;
  LocationPlace? _destination;

  LatLng? get selectedLocation => _selectedLocation;
  String? get currentAddress => _currentAddress;

  LocationPlace? get origin => _origin;
  LocationPlace? get destination => _destination;

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
        _currentAddress =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      } else {
        _currentAddress =
            "${newLocation.latitude.toStringAsFixed(5)}, ${newLocation.longitude.toStringAsFixed(5)}";
      }
    } catch (e) {
      _currentAddress = "Dirección no disponible";
    }

    notifyListeners();
  }

  void setOrigin(LocationPlace data) {
    _origin = data;
    originController.text = data.address;
    notifyListeners();
  }

  void setDestination(LocationPlace data) {
    _destination = data;
    destinationController.text = data.address;
    notifyListeners();
  }

  void swapLocations() {
    final temp = _origin;

    _origin = _destination;
    _destination = temp;

    originController.text = _destination?.address ?? "";
    destinationController.text = _origin?.address ?? "";

    notifyListeners();
  }

  void clear() {
    originController.clear();
    destinationController.clear();
    _origin = _destination = _selectedLocation = null;

    notifyListeners();
  }
}
