import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleSignIn() async {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      navigator.pop();
    } on FirebaseAuthException catch (e) {
      navigator.pop();
      _showErrorMessage(e.code);
    }
  }

  void _showErrorMessage(String code) {
    String msg = 'Erro ao realizar login.';
    if (code == 'invalid-credential') msg = 'Credenciais inválidas!';
    if (code == 'invalid-email') msg = 'Informe um e-mail válido!';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.sports_soccer, size: 100, color: Colors.green),
                const SizedBox(height: 10),
                Text('ArenaScout AI', style: TextStyle(color: Colors.grey[800], fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                MyTextField(controller: _emailController, hintText: 'Email', icon: const Icon(Icons.email_outlined), obscureText: false, capitalization: false),
                const SizedBox(height: 15),
                MyTextField(controller: _passwordController, hintText: 'Senha', icon: const Icon(Icons.lock_outline), obscureText: true, capitalization: false),
                const SizedBox(height: 25),
                MyButton(onPressed: _handleSignIn, formKey: _formKey, text: 'Logar'),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Novo por aqui? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Registre-se', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}