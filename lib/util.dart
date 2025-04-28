import 'dart:math';

import 'package:geolocator/geolocator.dart';

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Raggio della Terra in km

  double toRadians(double degree) => degree * pi / 180.0;

  final dLat = toRadians(lat2 - lat1);
  final dLon = toRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRadians(lat1)) * cos(toRadians(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}

double calculateTotalDistance(List<Map<String, dynamic>> coordinates) {
  double totalDistance = 0.0;

  for (int i = 0; i < coordinates.length - 1; i++) {
    final start = coordinates[i];
    final end = coordinates[i + 1];

    double lat1 = start['lat'];
    double lon1 = start['lon'];
    double lat2 = end['lat'];
    double lon2 = end['lon'];

    totalDistance += haversineDistance(lat1, lon1, lat2, lon2);
  }

  return totalDistance;
}

double calculateTotalDistanceFromPositions(List<Position> positions) {
  double totalDistance = 0.0;

  for (int i = 0; i < positions.length - 1; i++) {
    final start = positions[i];
    final end = positions[i + 1];

    totalDistance += haversineDistance(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  return totalDistance;
}
