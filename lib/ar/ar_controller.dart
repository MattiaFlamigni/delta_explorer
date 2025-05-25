import 'package:delta_explorer/database/supabase.dart';

class ARController{
  final SupabaseDB _db = SupabaseDB();
  List<Map<String, dynamic>> models = [];


  Future<void> fetchModels()async{
    var response = await _db.getARModels();
    models = response;
  }

  List<Map<String, dynamic>> getModels(){
    return models;
  }


}