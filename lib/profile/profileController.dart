import 'package:delta_explorer/database/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController{
  final SupabaseDB _db = SupabaseDB();
  final GoTrueClient _auth = Supabase.instance.client.auth;


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


}