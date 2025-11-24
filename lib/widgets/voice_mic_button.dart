import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';

class VoiceMicButton extends StatelessWidget {
  final double size;
  const VoiceMicButton({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceProvider>(
      builder: (context, voice, child) {
        final isListening = voice.isListening;
        final isProcessing = voice.isProcessing;

        return GestureDetector(
          onTap: () {
            if (isProcessing) return;

            if (isListening) {
              voice.stopListening();
            } else {
              voice.startListening();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size * 1.5,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              color: isProcessing
                  ? Colors.orange
                  : isListening
                      ? Colors.red
                      : Colors.blue,
              boxShadow: isListening
                  ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              isProcessing
                  ? Icons.hourglass_top
                  : isListening
                      ? Icons.mic
                      : Icons.mic_none,
              size: 24,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
