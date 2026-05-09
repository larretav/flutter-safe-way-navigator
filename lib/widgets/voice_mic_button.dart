import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/models/gpt_resp_model.dart';
import 'package:safe_way_navigator/models/location_model.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';
import 'package:safe_way_navigator/services/place_service.dart';
import '../providers/voice_provider.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places;

class VoiceMicButton extends StatelessWidget {
  final double size;
  const VoiceMicButton({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final voiceProvider = Provider.of<VoiceProvider>(context);

    if (!voiceProvider.isWakeWordInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VoiceProvider>().initWakeWord(() {
          _handleTap(context, context.read<VoiceProvider>(), context.read<MapProvider>());
        });
      });
    }

    return GestureDetector(
      onTap: () => _handleTap(context, voiceProvider, mapProvider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size * 1.5,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12),
          color: voiceProvider.isProcessing
              ? Colors.orange
              : voiceProvider.isListening
                  ? Colors.red
                  : Colors.blue,
          boxShadow: voiceProvider.isListening
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
          voiceProvider.isProcessing
              ? Icons.hourglass_top
              : voiceProvider.isListening
                  ? Icons.mic
                  : Icons.mic_none,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateOption(NavigateGPTRespModel nav, BuildContext context) async {
    final mapProvider = context.read<MapProvider>();
    final PlaceService placeService = PlaceService();
    final latlng = mapProvider.currentLocation;
    final placesCurrentLoc = places.LatLng(
        lat: mapProvider.currentLocation!.latitude, lng: mapProvider.currentLocation!.longitude);

    if (latlng == null || mapProvider.origin == null) return;

    LocationPlace originPlace = mapProvider.origin!;

    // Establecer origen
    if (nav.origin == "current_location") {
      originPlace = LocationPlace(
          address: originPlace.address, latlng: gmaps.LatLng(latlng.latitude, latlng.longitude));
    } else {
      final results = await placeService.search(nav.origin, placesCurrentLoc);

      if (results.isEmpty && context.mounted) {
        _showSnackBar("Algo salió mal al buscar el origen", context);
        return;
      }

      final firstResult = results.first;
      final loc = await placeService.getPlaceLatLng(firstResult.placeId);
      if (loc == null && context.mounted) {
        _showSnackBar("Algo salió mal al obtener el lugar de origen", context);
        return;
      }

      originPlace =
          LocationPlace(address: firstResult.fullText, latlng: gmaps.LatLng(loc!.lat, loc.lng));
    }

    // Establecer destino
    final destResults = await placeService.search(nav.destination, placesCurrentLoc);

    if (destResults.isEmpty && context.mounted) {
      _showSnackBar("Algo salió mal al buscar el destino", context);
      return;
    }

    final firstResult = destResults.first;
    final loc = await placeService.getPlaceLatLng(firstResult.placeId);

    if (loc == null && context.mounted) {
      _showSnackBar("Algo salió mal al obtener el lugar de origen", context);
      return;
    }

    mapProvider.setOrigin(LocationPlace(
        address: originPlace.address, latlng: gmaps.LatLng(latlng.latitude, latlng.longitude)));

    mapProvider.setDestination(LocationPlace(
        address: destResults.first.fullText, latlng: gmaps.LatLng(loc!.lat, loc.lng)));

    if (mapProvider.origin != null && mapProvider.destination != null) {
      mapProvider.drawRoute();
    }
  }

  void _reportOption(ReportGPTRespModel report, BuildContext context) {
    Navigator.pushNamed(context, '/report', arguments: report);
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  _handleTap(BuildContext context, VoiceProvider voice, MapProvider mapProvider) async {
    final result = await voice.recordAndProcess(mapProvider.currentLocation);
    if (result == null || !context.mounted) {
      if (context.mounted) _showSnackBar("Algo salió mal", context);
      return;
    }

    if (result is UnknownGPTRespModel) {
      if (context.mounted) _showSnackBar("No se reconoció la instrucción", context);
    }

    if (result is NavigateGPTRespModel) {
      _navigateOption(result, context);
    }

    if (result is ReportGPTRespModel) {
      _reportOption(result, context);
    }
  }
}
