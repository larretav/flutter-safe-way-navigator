import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/models/gpt_resp_model.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';
import 'package:safe_way_navigator/services/place_service.dart';
import '../providers/voice_provider.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class VoiceMicButton extends StatelessWidget {
  final double size;
  const VoiceMicButton({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Consumer<VoiceProvider>(
      builder: (context, voice, child) {
        final isListening = voice.isListening;
        final isProcessing = voice.isProcessing;

        return GestureDetector(
          onTap: () {
            if (isProcessing || mapProvider.currentLocation == null) return;

            if (isListening) {
              final result = voice.stopListening();
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

  void _navigateOption(NavigateGPTRespModel nav, BuildContext context) async {
    final mapProvider = context.read<MapProvider>();
    final PlaceService placeService = PlaceService();

    final results = await placeService.search(
        nav.origin,
        LatLng(
            lat: mapProvider.currentLocation!.latitude,
            lng: mapProvider.currentLocation!.longitude));

    if (results.isNotEmpty) {
      final loc = await placeService.getPlaceLatLng(results.first.placeId);
    }
  }

  void _reportOption(ReportGPTRespModel report) {
    print("Incidente: ${report.incidentType}");
  }
}
