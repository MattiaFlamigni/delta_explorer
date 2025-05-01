import 'package:delta_explorer/MainPage.dart';
import 'package:delta_explorer/login/loginController.dart';
import 'package:delta_explorer/login/registration.dart';
import 'package:delta_explorer/profile/profile.dart';
import 'package:flutter/material.dart';

import '../home/home.dart';

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
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.blueAccent,
        elevation: 0, // rimuove la linea sotto l'AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                drawHeadPage(),
                SizedBox(height: 40),
                // Email TextField
                _buildTextField(_emailController, 'Email', false),
                SizedBox(height: 16),
                // Password TextField
                _buildTextField(_passwordController, 'Password', true),
                SizedBox(height: 20),
                // Buttons Row
                drawRowButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawHeadPage(){
    return Column(
      children: [
        Text(
          'Benvenuto!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Accedi per continuare',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        hintText: 'Inserisci $label',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Row with buttons
  Widget drawRowButton() {
    return Column(
      children: [
        _loading
            ? CircularProgressIndicator()
            : _buildButton('Login', () async {
          var res = await controller.submitLogin(
            _emailController.text,
            _passwordController.text,
          );
          if (res == "Ok") {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Profile()),
            );
          } else {
            showSnackbar(res);
          }
        }),
        SizedBox(height: 16),
        _buildButton('Registrati', () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RegisterForm()),
          );
        }),

        SizedBox(height: 16),
        _buildButton('Torna alla Home', () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
                (route) => false, // Rimuove tutte le route precedenti
          );

        }),

      ],
    );
  }

  // Custom button with gradient and hover effect
  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(

        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5, // shadow effect
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Snackbar for showing messages
  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
