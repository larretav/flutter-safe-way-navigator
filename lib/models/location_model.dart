
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class LocationPlace {
  final String address;
  final LatLng latlng;

  LocationPlace({
    required this.address,
    required this.latlng,
  });

  factory LocationPlace.getEmpty() => LocationPlace(address: "", latlng: const LatLng(lat: 0, lng: 0));
}