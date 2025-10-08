import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de reportes"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('HistoryScreen'),
      ),
    );
  }
}
