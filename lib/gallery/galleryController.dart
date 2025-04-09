import 'package:delta_explorer/database/supabase.dart';

class galleryController{
  SupabaseDB db = SupabaseDB();


  Future<List<Map<String, dynamic>>> getReports() async {
    var spotted = await db.getData(table: "spotted");
    return spotted;
  }
}