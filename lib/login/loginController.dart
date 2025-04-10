import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController{
  final GoTrueClient _auth = Supabase.instance.client.auth;


  Future<String> signUpNewUser(String email, String password) async {
    try {
      print("Tentativo di registrazione con l'email: $email"); // Aggiungi il print dell'email
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      print("Risposta dalla registrazione: ${res.toString()}"); // Stampa la risposta completa di Supabase

      final user = res.user;
      if (user != null) {
        print("Utente registrato con successo: ${user.email}"); // Stampa l'email dell'utente
        return "Registrazione avvenuta con successo";
      } else {
        print("Utente non trovato dopo la registrazione."); // Aggiungi un messaggio per quando l'utente è null
        return "Registrazione avviata, ma senza utente. Verifica l’email.";
      }

    } on AuthException catch (e) {
      print("Errore di autenticazione: ${e.message}"); // Stampa l'errore specifico di autenticazione
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