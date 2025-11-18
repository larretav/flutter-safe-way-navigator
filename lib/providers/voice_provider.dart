import 'package:flutter/material.dart';

class VoiceProvider extends ChangeNotifier {
  bool _isListening = false;
  bool _isProcessing = false;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;

  /// Cuando el usuario presiona el botón de micrófono
  void startListening() {
    if (_isProcessing) return; // evita conflicto
    _isListening = true;
    notifyListeners();
  }

  /// Cuando el usuario deja de hablar o cancela
  void stopListening() {
    _isListening = false;
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
