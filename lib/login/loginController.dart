import 'package:delta_explorer/database/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController{
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseDB db = SupabaseDB();




  Future<String> submitLogin(String mail, String password) async {
    if(mail.isEmpty){
      return "inserire mail";
    }
    var res = await signInWithEmail(mail, password,);
    return res;
  }


  Future<String> signUpNewUser(String email, String password) async {
    try {
      print("Tentativo di registrazione con l'email: $email");
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      print("Risposta dalla registrazione: ${res.toString()}");

      final user = res.user;
      if (user != null) {
        print("Utente registrato con successo: ${user.email}");
        //aggiungo l'id alla tabella del database pubblico ; points=0
        db.addUser(user);
        return "Registrazione avvenuta con successo";
      } else {
        print("Utente non trovato dopo la registrazione.");
        return "Registrazione avviata, ma senza utente. Verifica l’email.";
      }

    } on AuthException catch (e) {
      print("Errore di autenticazione: ${e.message}"); //
      return "Errore di autenticazione: ${e.message}";
    } catch (e) {
      print("Errore generico: $e"); // Stampa qualsiasi errore generico
      return "Errore generico: $e";
    }
  }

  bool checkConfirmPassword(String psw1, String psw2){
    return psw1==psw2;
  }


  Future<String> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse res = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        return "Ok";
      } else {
        return "Credenziali errate";
      }

    } on AuthException catch (e) {
      // Gestione errori specifici di Supabase Auth
      return "Errore di autenticazione: ${e.message}";
    } catch (e) {
      return "Errore generico: $e";
    }
  }

}