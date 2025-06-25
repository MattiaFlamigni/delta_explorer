import 'package:delta_explorer/database/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseDB _db = SupabaseDB();

  Future<String> submitLogin(String mail, String password) async {
    if (mail.isEmpty) {
      return "inserire mail";
    }
    var res = await signInWithEmail(mail, password);
    return res;
  }

  Future<String> signUpNewUser(
    String email,
    String password,
    String username,
  ) async {
    if (await _db.isUsernameAvailable(username)) {
      try {
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        final user = res.user;
        if (user != null) {
          //aggiungo l'id alla tabella del database pubblico ; points=0
          await _db.addUser(user, username); //TODO: STRING?
          return "Registrazione avvenuta con successo";
        } else {
          return "Registrazione avviata, ma senza utente. Verifica l’email.";
        }
      } on AuthException catch (e) {
        return "Errore di autenticazione: ${e.message}";
      } catch (e) {
        return "Errore generico: $e";
      }
    } else {
      return "Utente gia esistente";
    }
  }

  bool checkConfirmPassword(String psw1, String psw2) {
    return psw1 == psw2;
  }

  /*Future<void> sendResetPasswordEmail(String email) async {
    await _db.supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: "http://127.0.0.1/deltaExplorer/",
    );
  }*/

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
