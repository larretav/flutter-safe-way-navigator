import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          Container(
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Text(
              "Mapa aquí",
              style: TextStyle(fontSize: 24, color: Colors.black54),
            ),
          ),

          // 🔹 Inputs en la parte superior
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Origen",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Destino",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 🔹 Botón de intercambiar origen/destino
                    IconButton(
                      icon: const Icon(Icons.swap_vert_circle, size: 32),
                      onPressed: () {
                        // TODO: intercambiar valores
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Parte inferior: comandos y botones
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Di: 'Ir de la universidad a mi casa'",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Botón Reportar incidente
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, "/report");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.warning),
                        label: const Text("Reportar"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón Reconocimiento de voz
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: activar reconocimiento de voz
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.mic),
                        label: const Text("Voz"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // 🔹 Botón flotante → historial
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/history");
        },
        child: const Icon(Icons.history),
      ),
    );
  }
}
