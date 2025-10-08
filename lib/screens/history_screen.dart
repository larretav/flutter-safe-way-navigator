import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../widgets/report_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final reports = reportProvider.reports;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Reportes"),
        centerTitle: true,
      ),
      body: reports.isEmpty
          ? const Center(
              child: Text(
                "No hay reportes registrados",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(report: report);
              },
            ),
    );
  }
}
