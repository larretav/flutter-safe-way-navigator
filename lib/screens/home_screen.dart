import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';

class HomeScreen extends StatelessWidget {
  final LatLng _center = const LatLng(25.7903, -108.9859);

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas Seguras"),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 Mapa simulado (placeholder)
          GoogleMap(
            onMapCreated: mapProvider.onMapCreated,
            onCameraMove: (position) {
              mapProvider.updateCoords(position.target);
            },
            onCameraIdle: () {
              mapProvider.updateLocation(mapProvider.selectedLocation);
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          const IgnorePointer(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),

          // 🔹 Inputs en la parte superior
          const OriginDest(),

          // 🔹 Parte inferior: comandos y botones
          const MapFooter(),
        ],
      ),
    );
  }
}

class MapFooter extends StatelessWidget {
  const MapFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, "/history");
              },
              child: const Icon(Icons.history),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.mic, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Di "Hola Mapa" para activar el Reconocimiento de voz',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Botón Reportar
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/report");
                    },
                    icon: const Icon(Icons.warning),
                    label: const Text("Reportar"),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón Voz
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.mic),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OriginDest extends StatelessWidget {
  const OriginDest({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Origen",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                  Divider(height: 1, thickness: 1),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Destino",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                // TODO: intercambiar origen/destino
              },
              icon: const Icon(Icons.swap_vert, size: 28),
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}
