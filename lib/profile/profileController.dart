import 'package:delta_explorer/database/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController{
  final SupabaseDB _db = SupabaseDB();
  final GoTrueClient _auth = Supabase.instance.client.auth;
  List<Map<String, dynamic>> _badge = [];
  double numSpotted=0;
  double numReport=0;
  int userPoint = -1;


  bool isUserLogged(){

    final user = _auth.currentUser;
    if(user!=null){
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> fetchBadge()async{
    List<Map<String, dynamic>> list = [];
    list = await _db.getData(table: "badge");
    _badge = list;
  }

  Future<void> loadNumSpotted() async{

    int num = await _db.countRowFromTableWhereUser("spotted", _auth.currentUser!.id) ?? 0;
    numSpotted = num.toDouble();

  }

  Future<void> loadNumReport() async{
    int num = await _db.countRowFromTableWhereUser("reports", _auth.currentUser!.id) ?? 0;
    print("num report: $num");
    numReport = num.toDouble();
  }

  double getNumSpotted()  {
    return numSpotted;
  }

  double getNumReport(){
    return numReport;
  }

  Future<void> fetchUserPoint() async {
    int point =  await  _db.getUserPoints(_auth.currentUser!.id);
    userPoint = point;
  }

  int getUserPoint(){
    return userPoint;
  }

  List<Map<String, dynamic>> getBadges(){
    return _badge;
  }






}