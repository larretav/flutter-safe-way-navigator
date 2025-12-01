import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:safe_way_navigator/models/gpt_resp_model.dart';
import 'package:safe_way_navigator/services/chatgpt_service.dart';
import '../services/whisper_service.dart';

import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';

class VoiceProvider extends ChangeNotifier {
  PorcupineManager? _porcupine;
  final _recorder = AudioRecorder();

  bool _isListening = false;
  bool _isProcessing = false;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;

  final String _porcupineApiKey = dotenv.env['PORCUPINE_API_KEY'] ?? "";

  /// Obtiene un archivo temporal para guardar la grabación
  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/voice_command_${DateTime.now().millisecondsSinceEpoch}.wav";
    return filePath;
  }

  // Inicializar WakeWord
  Future<void> initWakeWord(VoidCallback onWakeWord) async {
    try {
      print("Iniciando wake word $_porcupineApiKey");
      final ppnPath = await copyAssetToFile("assets/holamapa_es_android_v3_0_0.ppn");
      print(ppnPath);
      _porcupine = await PorcupineManager.fromKeywordPaths(
        _porcupineApiKey,
        [
          // BuiltInKeyword.PORCUPINE, BuiltInKeyword.OK_GOOGLE
          ppnPath,
        ],
        (int keywordIndex) => onWakeWord(),
      );

      await _porcupine!.start();
      debugPrint("Wake word listening...");
    } on PorcupineException catch (e) {
      debugPrint("Error al inicializar wake word: $e");
    }
  }

  /// Cuando el usuario presiona el botón de micrófono
  void startListening() async {
    if (_isProcessing) return; // evita conflicto
    // Pedir permisos
    if (await _recorder.hasPermission()) {
      _isListening = true;
      notifyListeners();

      final path = await _getTempFilePath();

      try {
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
      } catch (e) {
        print("Error al guardar archivo de audio: " + e.toString());
      }
    }
  }

  /// Cuando el usuario deja de hablar o cancela
  Future<GPTRespModel?> stopListening() async {
    _isListening = false;
    _isProcessing = true;
    notifyListeners();

    final path = await _recorder.stop();

    if (path != null) {
      try {
        final file = File(path);

        // Enviar audio a Whisper
        final text = await WhisperService.transcribe(file);

        if (text != null && text.trim().isNotEmpty) {
          _isProcessing = false;
          notifyListeners();
          return await ChatGPTService.interpretCommand(text);
        }
      } catch (e) {
        print("Error al transcribir audio: " + e.toString());
      }
    }

    _isProcessing = false;
    notifyListeners();
    return null;
  }

  /// Cuando estamos procesando el audio (Whisper después)
  void startProcessing() {
    _isProcessing = true;
    notifyListeners();
  }

  /// Cuando Whisper ya terminó
  void stopProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> disposeWakeWord() async {
    await _porcupine?.stop();
    await _porcupine?.delete();
  }

  Future<String> copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file =
        File('${(await getApplicationDocumentsDirectory()).path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }
}
