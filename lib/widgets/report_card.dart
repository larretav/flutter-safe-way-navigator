import 'package:flutter/material.dart';
import '../models/report_model.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "grave":
        return Colors.red;
      case "moderado":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: _severityColor(report.severity),
          size: 36,
        ),
        title: Text(
          report.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${report.address}\n${_formatDate(report.date)}",
          style: const TextStyle(fontSize: 13),
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _severityColor(report.severity).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            report.severity,
            style: TextStyle(
              color: _severityColor(report.severity),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return "Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}
