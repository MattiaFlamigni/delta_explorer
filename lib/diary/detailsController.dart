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





}