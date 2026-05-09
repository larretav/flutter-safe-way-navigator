import 'dart:math' as Math;

double kmToDegLat(double km) => km / 111.0;
double kmToDegLng(double km, double lat) => km / (111.0 * Math.cos(lat * Math.pi / 180));
