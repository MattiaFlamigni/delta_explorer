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
  final TextEditingController _usernameController =
  TextEditingController();
  LoginController controller = LoginController();

  bool _loading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrati"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
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
                Text(
                  'Crea un account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Inserisci i tuoi dati per registrarti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                // Email TextField
                _buildTextField(_emailController, 'Email', false),
                SizedBox(height: 16),
                //username
                _buildTextField(_usernameController, 'username', false),
                SizedBox(height: 16),
                // Password TextField
                _buildTextField(_passwordController, 'Password', true),
                SizedBox(height: 16),
                // Confirm Password TextField
                _buildTextField(_confirmPasswordController, 'Conferma Password', true),
                SizedBox(height: 20),
                // Button Row
                drawRowButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text Field
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
            : _buildButton('Registrati', () async {
          showRegistrationMessage();
        }),
        SizedBox(height: 16),
        _buildButton('Hai già un account? Accedi', () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => LoginForm()),
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
        elevation: 5,
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

  // Registration message
  showRegistrationMessage() async {
    if (controller.checkConfirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    ) == false) {
      showSnackbar("Le password non coincidono");
      return;
    }
    if (_passwordController.text.length < 6) {
      showSnackbar("La password deve essere almeno 6 caratteri");
      return;
    }
    if (_usernameController.text.isEmpty) {
      showSnackbar("Inserire Username");
      return;
    }
    var res = await controller.signUpNewUser(
      _emailController.text,
      _passwordController.text,
      _usernameController.text
    );

    if (res == "Registrazione avvenuta con successo") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    } else {
      showSnackbar(res);
    }
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
