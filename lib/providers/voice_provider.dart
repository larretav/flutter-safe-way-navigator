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
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VoiceProvider extends ChangeNotifier {
  PorcupineManager? _porcupine;
  final _recorder = AudioRecorder();

  bool _isListening = false;
  bool _isProcessing = false;
  bool _isWakeWordInitialized = false;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isWakeWordInitialized => _isWakeWordInitialized;

  final String _porcupineApiKey = dotenv.env['PORCUPINE_API_KEY'] ?? "";

  /// Obtiene un archivo temporal para guardar la grabación
  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/voice_command_${DateTime.now().millisecondsSinceEpoch}.wav";
    return filePath;
  }

  // Inicializar WakeWord
  Future<void> initWakeWord(VoidCallback onWakeWord) async {
    if (_isWakeWordInitialized) return;
    try {
      print("Porcupine: Iniciando wake word...");

      _porcupine = await PorcupineManager.fromKeywordPaths(
          _porcupineApiKey,
          [
            "assets/hola-mapa_es_android_v3_0_0.ppn",
          ],
          (int keywordIndex) => onWakeWord(),
          modelPath: "assets/porcupine_params_es.pv");

      _isWakeWordInitialized = true;
      notifyListeners();
      await _porcupine!.start();
      debugPrint("Porcupine: listening...");
    } on PorcupineException catch (e) {
      debugPrint("Porcupine: Error al inicializar wake word: $e");
    }
  }

  // Iniciar grabacion, esperar y procesar
  Future<GPTRespModel?> recordAndProcess(LatLng? currentLocation) async {
    if (currentLocation == null) return null;
    await _porcupine?.stop();

    // Pedir permisos
    if (await _recorder.hasPermission()) {
      _isListening = true;
      notifyListeners();

      final path = await _getTempFilePath();

      await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
          ),
          path: path);

      return await Future.delayed(const Duration(seconds: 5), () async {
        if (await _recorder.isRecording()) {
          return await stopListening();
        } else {
          return null;
        }
      });
    } else {
      return null;
    }
  }

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
          await _porcupine?.start();
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
}
