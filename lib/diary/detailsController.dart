import 'dart:math';

import '../database/supabase.dart';

class DetailsController{
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> images = [];
  List<Map<String, dynamic>> coord = [];


  Future<void> fetchImagesPaths(String title)async{
    images = await _db.getImagesUrl(title);
    print("immagini: $images");
  }

  List<Map<String, dynamic>> getImages(){
    return images;
  }

  Future<void> fetchCoord(int tripId)async {
    var list = await _db.getCoordByTripId(tripId);
    coord = list;
    print("lista coordinate : $list");
  }

  List<Map<String, dynamic>>getCoord() {
    return coord;
  }

  // Funzione per calcolare la distanza tra due coordinate
  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Raggio della Terra in km

    double toRadians(double degree) => degree * pi / 180.0;

    final dLat = toRadians(lat2 - lat1);
    final dLon = toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(lat1)) * cos(toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // distanza in km
  }

// Funzione che prende una lista di coordinate e calcola la distanza totale
  // Funzione per lista di mappe
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






}