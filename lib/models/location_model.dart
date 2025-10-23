

import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPlace {
  final String address;
  final LatLng latlng;

  LocationPlace({
    required this.address,
    required this.latlng,
  });

  factory LocationPlace.getEmpty() => LocationPlace(address: "", latlng: const LatLng(0, 0));
}