import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class PlaceService {
  final FlutterGooglePlacesSdk _places = FlutterGooglePlacesSdk(dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "");

  Future<List<AutocompletePrediction>> search(String query, LatLng latlng) async {
    print('-----------------Buscando: $query, $latlng -----------------');

    if (query.isEmpty) return [];

    final result = await _places.findAutocompletePredictions(
      query,
      countries: ['MX'],
      origin: latlng// Los Mochis

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
