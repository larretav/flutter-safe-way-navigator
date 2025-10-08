import 'package:flutter/material.dart';
import '../models/report_model.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

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
          color: report.severityColor,
          size: 36,
        ),
        title: Text(
          report.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${report.address}\n${report.formattedDate}",
          style: const TextStyle(fontSize: 13),
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: report.severityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            report.severity,
            style: TextStyle(
              color: report.severityColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
