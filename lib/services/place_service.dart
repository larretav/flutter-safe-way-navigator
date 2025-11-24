import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:safe_way_navigator/utils/latlng.utils.dart';

class PlaceService {
  final FlutterGooglePlacesSdk _places =
      FlutterGooglePlacesSdk(dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "");

  Future<List<AutocompletePrediction>> search(String query, LatLng latlng) async {
    if (query.isEmpty) return [];

    // Agregamos un limite de 50km a la busqueda
    const double km = 50;

    final latDelta = kmToDegLat(km);
    final lngDelta = kmToDegLng(km, latlng.lat);

    final southwest = LatLng(lat: latlng.lat - latDelta, lng: latlng.lng - lngDelta);
    final northeast = LatLng(lat: latlng.lat + latDelta, lng: latlng.lng + lngDelta);

    final result = await _places.findAutocompletePredictions(query,
        countries: ['MX'],
        origin: latlng, // Los Mochis
        locationBias: LatLngBounds(
          southwest: southwest,
          northeast: northeast,
        ));
    return result.predictions;
  }

  Future<LatLng?> getPlaceLatLng(String placeId) async {
    final details = await _places.fetchPlace(placeId, fields: [PlaceField.Location]);

    final loc = details.place?.latLng;

    if (loc == null) return null;
    return LatLng(lat: loc.lat, lng: loc.lng);
  }
}
