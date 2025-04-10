import 'package:delta_explorer/login/login.dart';
import 'package:delta_explorer/profile/profileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}


class _profileState extends State<profile> {

  ProfileController controller = ProfileController();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final isLoggedIn = controller.isUserLogged();

    return Scaffold(

    );
  }



  registration(){
    return Scaffold();
  }


}

