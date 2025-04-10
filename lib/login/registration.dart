import 'package:delta_explorer/login/login.dart';
import 'package:delta_explorer/login/loginController.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  LoginController controller = LoginController();

  bool _loading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrati")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showRegistrationForm()
      ),
    );
  }

  showRegistrationMessage() async {
    if (controller.checkConfirmPassword(
          _passwordController.text,
          _confirmPasswordController.text,
        ) ==
        false) {
      showSnackbar("le password non coincidono");
      return;
    }
    if (_passwordController.text.length < 6) {
      showSnackbar("La password deve essere almeno 6 caratteri");
      return;
    }
    var res = await controller.signUpNewUser(
      _emailController.text,
      _passwordController.text,
    );

    if(res=="Registrazione avvenuta con successo"){
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    }else{
      showSnackbar(res);
    }
  }

  Widget drawButon(){
    return _loading
        ? CircularProgressIndicator()
        : ElevatedButton(
      onPressed: () async {
        showRegistrationMessage();
      },
      child: Text('Registrati'),
    );
  }

  Widget showRegistrationForm(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Conferma Password'),
        ),
        SizedBox(height: 20),

        drawButon()
      ],
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
