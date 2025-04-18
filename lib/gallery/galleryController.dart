import 'package:delta_explorer/database/supabase.dart';

class galleryController{
  SupabaseDB db = SupabaseDB();
  List<Map<String, dynamic>> _spottedList = [];


  Future<void> fetchSpotted() async {
    var spotted = await db.getData(table: "spotted");
    print("LISTA IMMAGINI $spotted");
    _spottedList = spotted;
  }

  List<Map<String,dynamic>> getSpottedList(){
    return _spottedList;
  }
}