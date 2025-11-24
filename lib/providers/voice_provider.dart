import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:safe_way_navigator/services/chatgpt_service.dart';
import '../services/whisper_service.dart';

class VoiceProvider extends ChangeNotifier {
  final _recorder = AudioRecorder();

  bool _isListening = false;
  bool _isProcessing = false;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;

  /// Obtiene un archivo temporal para guardar la grabación
  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/voice_command_${DateTime.now().millisecondsSinceEpoch}.wav";
    return filePath;
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
  void stopListening() async {
    _isListening = false;
    _isProcessing = true;
    notifyListeners();

    final path = await _recorder.stop();

    if (path != null) {
      try {
        final file = File(path);

        // Enviar audio a Whisper
        final text = await WhisperService.transcribe(file);

        debugPrint("Texto recibido de Whisper: $text");
        if (text != null && text.trim().isNotEmpty) {
          final result = await ChatGPTService.interpretCommand(text);
          debugPrint("Interpretación: $result");

          // TODO: mandar este JSON al MapProvider

          // o abrir la pantalla de reporte
        }
      } catch (e) {
        print("Error al transcribir audio: " + e.toString());
      }
    }

    _isProcessing = false;
    notifyListeners();
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
}
