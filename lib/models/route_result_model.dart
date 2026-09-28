import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double baseDurationMinutes;
  final double adjustedTimeMinutes;
  final String riskLevel;
  final bool allRisky;
  final List<String> tips;

  RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.baseDurationMinutes,
    required this.adjustedTimeMinutes,
    required this.riskLevel,
    required this.allRisky,
    required this.tips,
  });
}
