import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe_way_navigator/models/location_model.dart';
import 'package:safe_way_navigator/providers/map_provider.dart';
import 'package:safe_way_navigator/widgets/address_autocomplete.dart';
import 'package:safe_way_navigator/widgets/map.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rutas Seguras",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        toolbarHeight: 48,
      ),
      body: const Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 Mapa simulado (placeholder)
          TheMap(),

          OriginDest(),

          // 🔹 Parte inferior: comandos y botones
          MapFooter(),
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
            FloatingActionButton.small(
              heroTag: "centerLocation",
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              onPressed: mapProvider.moveToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
            const SizedBox(height: 10),
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
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
    final mapProvider = Provider.of<MapProvider>(context);

    return Positioned(
      top: 10,
      left: 18,
      right: 18,
      child: Container(
        padding: const EdgeInsets.only(
            left: 12, right: 4, bottom: 8, top: 8), //symmetric(horizontal: 12, vertical: 8),
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
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: AddressAutocomplete(
                      hintText: "Origen",
                      controller: mapProvider.originController,
                      onPlaceSelected: (address, latlng) {
                        mapProvider.setOrigin(LocationPlace(
                            address: address, latlng: LatLng(latlng.lat, latlng.lng)));
                        if (mapProvider.origin != null && mapProvider.destination != null) {
                          mapProvider.drawRoute();
                        }
                      },
                      onCleared: () {
                        mapProvider.setOrigin(null);
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: AddressAutocomplete(
                      hintText: "Destino",
                      controller: mapProvider.destinationController,
                      onPlaceSelected: (address, latlng) {
                        mapProvider.setDestination(LocationPlace(
                            address: address, latlng: LatLng(latlng.lat, latlng.lng)));
                        if (mapProvider.origin != null && mapProvider.destination != null) {
                          mapProvider.drawRoute();
                        }
                      },
                      onCleared: () {
                        mapProvider.setOrigin(null);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                mapProvider.swapLocations();
              },
              icon: const Icon(Icons.swap_vert, size: 24),
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
