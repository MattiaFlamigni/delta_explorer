import 'dart:math';

import 'package:delta_explorer/database/supabase.dart';
import 'package:geolocator/geolocator.dart';

class DiscoverController {
  final SupabaseDB _db = SupabaseDB();
  List<dynamic> _poi = [];

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  double distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // metri
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * pi / 180;

  Future<void> getNearPoi({double radius = 1000}) async {
    final position = await getUserLocation();
    final userLat = position.latitude;
    final userLon = position.longitude;

    final allPois = await _db.getPOI();
    final nearbyPois =
        allPois.where((poi) {
          final location = poi["location"];
          if (location == null) return false;

          final lat = location['latitude'];
          final lon = location['longitude'];

          if (lat == null || lon == null) return false;

          final distance = distanceInMeters(userLat, userLon, lat, lon);
          return distance <= radius;
        }).toList();

    _poi = nearbyPois;
  }

  getNearPoiList() {
    return _poi;
  }
}
