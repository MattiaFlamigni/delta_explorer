import 'package:delta_explorer/database/supabase.dart';

class StandingController{
  List<Map<String, dynamic>> _standing = [];
  final SupabaseDB _db = SupabaseDB();

  fetchGlobal_Week({bool week = false, bool month=false}) async{
    var list = await _db.global_weekStanding(week: week, month: month);
    print("$list");
    _standing = list;
  }


  getStanding(){
    return _standing;
  }


}