import 'package:delta_explorer/database/supabase.dart';

class galleryController{
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> _spottedList = [];


  Future<void> fetchSpotted() async {
    var spotted = await _db.getData(table: "spotted");
    _spottedList = spotted;
  }

  List<Map<String,dynamic>> getSpottedList(){
    return _spottedList.where((img) => img["image_path"]?.isNotEmpty == true).toList();
  }
}