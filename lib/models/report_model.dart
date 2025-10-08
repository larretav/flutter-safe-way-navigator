import 'dart:convert';

class Report {
  final String id;
  final String type;
  final String severity;
  final String address;
  final DateTime date;

  Report({
    required this.id,
    required this.type,
    required this.severity,
    required this.address,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        type: json["type"],
        severity: json["severity"],
        address: json["address"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "severity": severity,
        "address": address,
        "date": date.toIso8601String(),
      };

  String toJsonString() => json.encode(toMap());

  Report copy() => Report(
        id: id,
        type: type,
        severity: severity,
        address: address,
        date: date,
      );
}
