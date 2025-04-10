import 'package:delta_explorer/login/loginController.dart';
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
                  var res = await controller.signInWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  ); //TODO: NAVIGARE ALLA SCHERMATA PROFILO
                },
                child: Text('Login'),
              ),
              ElevatedButton(onPressed: (){}, child: Text("registrati")) //TODO: NAVIGARE ALLA SCHERMATA REGISTRATI
            ],
          )

        ],
      ),
    );
  }
}
