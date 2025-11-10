import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/models/location_model.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';

class TheMap extends StatefulWidget {
  const TheMap({
    super.key,
  });

  @override
  State<TheMap> createState() => _TheMapState();
}

class _TheMapState extends State<TheMap> {
  @override
  void dispose() {
    Provider.of<MapProvider>(context, listen: false).stopLocationTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    mapProvider.initialize();

    final location = mapProvider.currentLocation;
    if (location == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      onTap: (latlng) {
        if (mapProvider.origin == null) {
          FocusManager.instance.primaryFocus?.unfocus();
          mapProvider.setOrigin(
              LocationPlace(address: 'Mi ubicación', latlng: mapProvider.currentLocation!));
        }
      },
      onMapCreated: mapProvider.onMapCreated,
      initialCameraPosition: CameraPosition(
        target: mapProvider.currentLocation!,
        zoom: 14.0,
      ),
      myLocationEnabled: true,
      // myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      polylines: mapProvider.polylines,
    );
  }
}
