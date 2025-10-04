import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(25.7903, -108.9859);
  // Coordenadas de Los Mochis
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas Seguras"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🔹 Mapa simulado (placeholder)
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, "/history");
                },
                child: const Icon(Icons.history),
              ),
            ),
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
                  Text(
                    'Di "Hola Mapa" para activar el Reconocimiento de voz',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
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
            IconButton(
              onPressed: () {
                // TODO: intercambiar origen/destino
              },
              icon: const Icon(Icons.swap_vert_circle, size: 28),
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}
