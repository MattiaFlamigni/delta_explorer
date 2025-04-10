import 'package:delta_explorer/login/login.dart';
import 'package:delta_explorer/profile/profileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProfileController controller = ProfileController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  _checkLoginStatus() async {
    final isLoggedIn = controller.isUserLogged();
    print("loggato: $isLoggedIn");
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement( // Usa pushReplacement per evitare il ritorno
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Contenuto della schermata profilo quando l'utente è loggato
      appBar: AppBar(
        title: Text('Profilo'),
      ),
      body: Center(
        child: TextButton(onPressed: (){controller.signOut();}, child: Text("signout")) //TODO: VERSIONE DI TEST
      ),
    );
  }

  Widget registration() {
    return Scaffold(); // Dovrebbe contenere la UI di registrazione
  }
}