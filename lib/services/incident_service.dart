import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class IncidentService {
  static final String _baseUrl = dotenv.env['PROLOG_SERVER_URL'] ?? 'http://localhost:3001';

  static Future<void> reportIncident({
    required String roadName,
    required String type,
    required String severity,
    String? description,
  }) async {
    final url = Uri.parse('$_baseUrl/incidentes');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'roadName': roadName,
        'type': type,
        'severity': severity,
        'description': description,
      }),
    );

    if (response.statusCode != 201) {
      final data = json.decode(response.body);
      throw Exception(data['error'] ?? 'Error al reportar el incidente (${response.statusCode})');
    }
  }
}
