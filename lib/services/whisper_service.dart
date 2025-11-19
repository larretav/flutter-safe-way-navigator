import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WhisperService {
  static const String apiKey = "TU_API_KEY_DE_OPENAI";

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
      return jsonRes["text"];
    } else {
      print("Error en Whisper: $body");
      return null;
    }
  }
}
