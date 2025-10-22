import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:safe_way_navigator/models/location_model.dart';
import 'package:safe_way_navigator/services/directions_service.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController mapController;
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  Set<Polyline> _polylines = {};

  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  String? _currentAddress;
  bool _initialized = false;
  StreamSubscription<Position>? _positionStream;

  LocationPlace? _origin;
  LocationPlace? _destination;

  LatLng? get selectedLocation => _selectedLocation;
  String? get currentAddress => _currentAddress;
  LatLng? get currentLocation => _currentLocation;

  LocationPlace? get origin => _origin;
  LocationPlace? get destination => _destination;
  Set<Polyline> get polylines => _polylines;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await initializeLocationTracking();
  }

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
    FocusManager.instance.primaryFocus?.unfocus();

    final temp = _origin;

    _origin = _destination;
    _destination = temp;

    originController.text = _origin?.address ?? "";
    destinationController.text = _destination?.address ?? "";

    notifyListeners();
  }

  void clear() {
    originController.clear();
    destinationController.clear();
    _origin = _destination = _selectedLocation = null;

    notifyListeners();
  }

  // Current Location
  Future<void> initializeLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    // Pedir permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permisos de ubicación permanentemente denegados.');
    }

    // Obtener ubicación actual
    final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));

    _currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();

    //Escucha cambios de posición
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // metros antes de disparar una actualización
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position pos) {
      _currentLocation = LatLng(pos.latitude, pos.longitude);

      //Mueve la cámara si quieres seguimiento automático
      mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );

      updateLocation(_currentLocation);
      notifyListeners();
    });
  }

  Future<void> drawRoute() async {
    if (_origin == null || _destination == null) return;

    final points =
        await DirectionsService.getRoutePoints(_origin.latlng!, _destination.latlng!);

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: points,
      )
    };

    notifyListeners();

    // Opcional: centrar la cámara en la ruta
    final bounds = _getBounds(points);
    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? x0, x1, y0, y1;
    for (final LatLng p in points) {
      if (x0 == null) {
        x0 = x1 = p.latitude;
        y0 = y1 = p.longitude;
      } else {
        if (p.latitude > x1!) x1 = p.latitude;
        if (p.latitude < x0) x0 = p.latitude;
        if (p.longitude > y1!) y1 = p.longitude;
        if (p.longitude < y0) y0 = p.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  void moveToCurrentLocation() {
    if (_currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 16),
      );
      updateLocation(_currentLocation);
    }
  }

  // Detener actualizaciones (por ejemplo, al cerrar la app)
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }
}
