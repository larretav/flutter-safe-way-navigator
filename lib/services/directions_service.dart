import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

  static Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    final url = Uri.parse(
      '$_baseUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener la ruta');
    }

    final data = json.decode(response.body);
    final route = data['routes'].first;
    final polyline = route['overview_polyline']['points'];

    return _decodePolyline(polyline);
  }

  // 🔹 Decodifica la polyline codificada de Google a una lista de LatLng
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
