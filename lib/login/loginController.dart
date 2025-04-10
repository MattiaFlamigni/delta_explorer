import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController{
  final GoTrueClient _auth = Supabase.instance.client.auth;


  Future<String> signUpNewUser() async {
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: 'flami2002@gmail.com',
        password: 'example-password',
      );

      final user = res.user;

      if (user != null) {
        return "Registrazione avvenuta con successo. Controlla l'email per la conferma.";
      } else {
        return "Registrazione avviata, ma senza utente. Verifica l’email.";
      }

    } on AuthException catch (e) {
      return "Errore di autenticazione: ${e.message}";
    } catch (e) {
      return "Errore generico: $e";
    }
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