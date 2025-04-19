import 'package:delta_explorer/constants/point.dart';
import 'package:delta_explorer/database/supabase.dart';
import 'package:gotrue/src/types/user.dart';

class StandingController {
  List<Map<String, dynamic>> _standing = [];
  final SupabaseDB _db = SupabaseDB();
  int spottedPoints = 0;
  int reportPoints = 0;

  fetchGlobal_Week({bool week = false, bool month = false}) async {
    var list = await _db.global_weekStanding(week: week, month: month);
    print("$list");
    _standing = list;

    await aggiungiUsername();
  }

  Future<void> aggiungiUsername() async {
    for (int i = 0; i < _standing.length; i++) {
      if (_standing[i].containsKey("userID")) {
        final String userId = _standing[i]["userID"];
        final String username = await getUsernamefromId(userId);
        _standing[i]["username"] = username;
      }
    }
  }

  Future<String> getUsernamefromId(String userID) async {
    print("username trovato: ${_db.getUsernameFromID(userID)}");
    return _db.getUsernameFromID(userID);
  }

  Future<void> friendStanding() async {
    _standing = await _db.friendsStanding(_db.supabase.auth.currentUser!.id);
  }

  getStanding() {
    print("STANDING: $_standing");
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

  int getSpottedPoints() {
    return spottedPoints;
  }

  int getReportPoints() {
    return reportPoints;
  }

  getAuthUser() {
    print("ID CORRENTE: ${_db.supabase.auth.currentUser!.id}");
    return _db.supabase.auth.currentUser!.id;
  }

  Future<String> addFriend(String username) async {
    if (await _checkFriend(username)) {
      await _db.addFriends(_db.supabase.auth.currentUser!.id, username);
      return "Amico aggiunto con successo";
    }
    return "Amico non trovato";
  }

  Future<bool> _checkFriend(String username) async {
    return await _db.existFriend(username);
  }

  User? isUserAuth(){
    return _db.supabase.auth.currentUser;
  }
}
