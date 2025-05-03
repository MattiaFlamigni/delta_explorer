import 'dart:math';

import '../database/supabase.dart';

class DetailsController{
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _coord = [];


  Future<void> fetchImagesPaths(String title)async{
    _images = await _db.getImagesUrl(title);
    print("immagini: $_images");
  }

  List<Map<String, dynamic>> getImages(){
    return _images;
  }

  Future<void> fetchCoord(int tripId)async {
    var list = await _db.getCoordByTripId(tripId);
    _coord = list;
    print("lista coordinate : $list");
  }

  List<Map<String, dynamic>>getCoord() {
    return _coord;
  }





}