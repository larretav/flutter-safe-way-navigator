sealed class GPTRespModel {
  final String action;

  GPTRespModel(this.action);

  factory GPTRespModel.fromJson(Map<String, dynamic> json) {
    switch (json["action"]) {
      case "navigate":
        return NavigateGPTRespModel.fromJson(json);
      case "report_incident":
        return ReportGPTRespModel.fromJson(json);
      default:
        return UnknownGPTRespModel();
    }
  }
}

class NavigateGPTRespModel extends GPTRespModel {
  final String origin;
  final String destination;

  NavigateGPTRespModel({
    required this.origin,
    required this.destination,
  }) : super('navigate');

  factory NavigateGPTRespModel.fromJson(Map<String, dynamic> json) {
    return NavigateGPTRespModel(
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'action': action,
        'origin': origin,
        'destination': destination,
      };
}

class ReportGPTRespModel extends GPTRespModel {
  final String incidentType; // accident|traffic|flood|construction|other
  final String locationDescription;
  final String severity; // mild|moderate|severe

  ReportGPTRespModel({
    required this.incidentType,
    required this.locationDescription,
    required this.severity,
  }) : super('report_incident');

  factory ReportGPTRespModel.fromJson(Map<String, dynamic> json) {
    return ReportGPTRespModel(
      incidentType: json['incidentType'] ?? 'other',
      locationDescription: json['locationDescription'] ?? '',
      severity: json['severity'] ?? 'mild',
    );
  }

  Map<String, dynamic> toJson() => {
        'action': action,
        'incidentType': incidentType,
        'locationDescription': locationDescription,
        'severity': severity,
      };
}

class UnknownGPTRespModel extends GPTRespModel {
  UnknownGPTRespModel() : super('unknown');

  Map<String, dynamic> toJson() => {'action': action};
}
