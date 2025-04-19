import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/database/supabase.dart';

class StandingController{
  List<Map<String, dynamic>> _standing = [];
  final SupabaseDB _db = SupabaseDB();
  int spottedPoints=0;
  int reportPoints=0;

  fetchGlobal_Week({bool week = false, bool month=false}) async{
    var list = await _db.global_weekStanding(week: week, month: month);
    print("$list");
    _standing = list;
  }

  getStanding(){
    return _standing;
  }

  Future<void> _computeSpottedPoints() async {
    int points = await _db.getTypePoints(TypePoints.spotted);
    print("pointsController: $points");
    spottedPoints = points;
  }

  Future<void> _computeReportPoints() async {
    int points = await _db.getTypePoints(TypePoints.reports);
    reportPoints = points;
  }

  Future<void> fetchPoints() async {
    await _computeReportPoints();
    await _computeSpottedPoints();
  }

  int getSpottedPoints(){
    return spottedPoints;
  }

  int getReportPoints(){
    return reportPoints;
  }

  getAuthUser(){
    return _db.supabase.auth.currentUser!.id;
}


}