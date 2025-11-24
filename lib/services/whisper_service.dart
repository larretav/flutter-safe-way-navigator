import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WhisperService {
  static final String apiKey = dotenv.env['OPENIA_API_KEY'] ?? "";

  static Future<String?> transcribe(File audioFile) async {
    final url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

    final request = http.MultipartRequest("POST", url)
      ..headers["Authorization"] = "Bearer $apiKey"
      ..files.add(
        await http.MultipartFile.fromPath(
          "file",
          audioFile.path,
        ),
      )
      ..fields["model"] = "whisper-1";

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(body);
      print("Resp: $jsonRes");
      return jsonRes["text"];
    } else {
      print("Error en Whisper: $body");
      return null;
    }
  }
}
