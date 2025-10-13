import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class PlaceService {
  final FlutterGooglePlacesSdk _places = FlutterGooglePlacesSdk('AIzaSyDOOOh5RWBy7AJ5mfn-DzUrt5e_FcFrgV8');

  Future<List<AutocompletePrediction>> search(String query) async {
    if (query.isEmpty) return [];

    final result = await _places.findAutocompletePredictions(
      query,
      countries: ['MX'],
      origin: const LatLng(lat: 25.7903,lng: -108.9859) // Los Mochis
    );
    return result.predictions;
  }

  Future<LatLng?> getPlaceLatLng(String placeId) async {
    final details = await _places.fetchPlace(placeId, fields: [PlaceField.Location]);

    final loc = details.place?.latLng;

    if (loc == null) return null;
    return LatLng(lat: loc.lat, lng: loc.lng);
  }
}
