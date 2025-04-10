import 'package:delta_explorer/login/loginController.dart';
import 'package:delta_explorer/login/registration.dart';
import 'package:delta_explorer/profile/profile.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}



class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LoginController controller = LoginController();

  bool _loading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  if(_emailController.text.isEmpty){
                    showSnackbar("Inserire mail");
                    return;
                  }
                  var res = await controller.signInWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  ); //TODO: NAVIGARE ALLA SCHERMATA PROFILO
                  if(res!="Ok"){
                    showSnackbar(res);
                  }else{
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  }

                },
                child: Text('Login'),
              ),
              ElevatedButton(onPressed: (){Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegisterForm()),
              );}, child: Text("registrati")) //TODO: NAVIGARE ALLA SCHERMATA REGISTRATI
            ],
          )

        ],
      ),
    );
  }



  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
