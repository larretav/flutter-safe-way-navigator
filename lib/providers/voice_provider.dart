import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:safe_way_navigator/models/gpt_resp_model.dart';
import 'package:safe_way_navigator/services/chatgpt_service.dart';
import '../services/whisper_service.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VoiceProvider extends ChangeNotifier {
  static const String _wakeWordPhrase = "hola mapa";

  final stt.SpeechToText _wakeWordRecognizer = stt.SpeechToText();
  final _recorder = AudioRecorder();

  VoidCallback? _onWakeWord;
  bool _wakeWordPaused = false;

  bool _isListening = false;
  bool _isProcessing = false;
  bool _isWakeWordInitialized = false;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isWakeWordInitialized => _isWakeWordInitialized;

  /// Obtiene un archivo temporal para guardar la grabación
  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/voice_command_${DateTime.now().millisecondsSinceEpoch}.wav";
    return filePath;
  }

  /// Inicializa la escucha de la frase de activación ("Hola Mapa") usando
  /// el reconocedor de voz nativo del dispositivo (gratis, sin API key).
  Future<void> initWakeWord(VoidCallback onWakeWord) async {
    if (_isWakeWordInitialized) return;
    _onWakeWord = onWakeWord;

    final available = await _wakeWordRecognizer.initialize(
      onError: (error) => debugPrint("speech_to_text: error $error"),
      onStatus: (status) {
        debugPrint("speech_to_text: status $status");
        if (!_wakeWordPaused && (status == 'done' || status == 'notListening')) {
          _startWakeWordListening();
        }
      },
    );

    if (!available) {
      debugPrint("speech_to_text: reconocimiento de voz no disponible en este dispositivo.");
      return;
    }

    _isWakeWordInitialized = true;
    notifyListeners();
    _startWakeWordListening();
  }

  void _startWakeWordListening() {
    _wakeWordRecognizer.listen(
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 60),
        localeId: 'es_MX',
      ),
      onResult: (result) {
        final heard = result.recognizedWords.toLowerCase();
        if (heard.contains(_wakeWordPhrase)) {
          _wakeWordRecognizer.stop();
          _onWakeWord?.call();
        }
      },
    );
  }

  // Iniciar grabacion, esperar y procesar
  Future<GPTRespModel?> recordAndProcess(LatLng? currentLocation) async {
    if (currentLocation == null) return null;
    _wakeWordPaused = true;
    await _wakeWordRecognizer.stop();

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
          _resumeWakeWordListening();
          notifyListeners();
          return await ChatGPTService.interpretCommand(text);
        }
      } catch (e) {
        debugPrint("Error al transcribir audio: $e");
      }
    }

    _isProcessing = false;
    _resumeWakeWordListening();
    notifyListeners();
    return null;
  }

  void _resumeWakeWordListening() {
    _wakeWordPaused = false;
    if (_isWakeWordInitialized) _startWakeWordListening();
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
    _wakeWordPaused = true;
    await _wakeWordRecognizer.stop();
  }
}
