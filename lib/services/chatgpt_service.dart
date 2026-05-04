import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safe_way_navigator/models/gpt_resp_model.dart';

class ChatGPTService {
  static final String apiKey = dotenv.env['OPENIA_API_KEY'] ?? "";

  static Future<GPTRespModel?> interpretCommand(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final systemPrompt = """
Eres un asistente que interpreta comandos de voz para una aplicación de navegación y reportes de incidentes.

Tu tarea es transformar el texto del usuario en un JSON válido.

Si el usuario quiere:

1) Navegar. Debes interpretar si el usuario quiere ir a algun lugar:
Ejemplos (no tiene que ser estrictamente iguales):
- Ir al Ley
- Llévame a mi casa
- Ir desde el Tecnológico hasta Plaza Paseo

Debes devolver:
{
  "action": "navigate",
  "origin": "<texto> o <current_location>",
  "destination": "<texto>"
}

2) Reportar un incidente. Debes interpretar si el usuario quiere reportar un incidente, un choque, inundación, etc.:
Ejemplos (no tiene que ser estrictamente iguales):
- Choque en Rosales
- Inundación por la Centenario
- Accidente grave cerca del Ley
- Quiero hacer un reporte

Debes devolver:
{
  "action": "report_incident",
  "incidentType": "accident|traffic|flood|construction|other",
  "locationDescription": "<texto> o <current_location>",
  "severity": "mild|moderate|severe"
}

3) Si no entiendes:
{
  "action": "unknown"
}

IMPORTANTE:
- Responde EXCLUSIVAMENTE con JSON válido.
""";

    final body = {
      "model": "gpt-4o-mini", // Puedes usar otro modelo si quieres
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": text}
      ],
      "temperature": 0.3,
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final jsonRes = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final content = jsonRes["choices"][0]["message"]["content"];

      // Convertir a JSON real
      final jsonData = GPTRespModel.fromJson(jsonDecode(content));
      return jsonData;
    }

    print("Error interpretando comando: ${response.body}");
    return null;
  }
}
