import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:safe_way_navigator/models/location_model.dart';
import 'package:safe_way_navigator/models/route_result_model.dart';

class DirectionsService {
  static final String _baseUrl = dotenv.env['PROLOG_SERVER_URL'] ?? 'http://localhost:3001';

  static Future<RouteResult> getBestRoute(LocationPlace origin, LocationPlace destination) async {
    final url = Uri.parse('$_baseUrl/ruta-optima');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'origen': {
          'address': origin.address,
          'lat': origin.latlng.latitude,
          'lng': origin.latlng.longitude,
        },
        'destino': {
          'address': destination.address,
          'lat': destination.latlng.latitude,
          'lng': destination.latlng.longitude,
        },
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error al obtener la ruta (${response.statusCode})');
    }

    return RouteResult(
      points: _decodePolyline(data['overviewPolyline']),
      distanceMeters: (data['distanceMeters'] as num).toDouble(),
      baseDurationMinutes: (data['baseDurationMinutes'] as num).toDouble(),
      adjustedTimeMinutes: (data['adjustedTimeMinutes'] as num).toDouble(),
      riskLevel: data['riskLevel'] as String,
      allRisky: data['allRisky'] as bool,
      tips: List<String>.from(data['tips'] ?? []),
    );
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
