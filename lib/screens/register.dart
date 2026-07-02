import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _handleSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("As senhas não correspondem!")));
      return;
    }

    // 1. O SEGREDO: Salva o navegador do contexto atual ANTES do await
    final navigator = Navigator.of(context);

    // Mostra o pop-up
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final CollectionReference users = FirebaseFirestore.instance.collection('users');
      await users.doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'photoURL': 'https://ui-avatars.com/api/?name=${_nameController.text}&background=00796B&color=fff'
      });

      // 2. Fecha o pop-up usando a referência salva, SEM usar o 'if (mounted)'
      navigator.pop();

    } on FirebaseAuthException catch (e) {
      // Também fecha o pop-up se der erro!
      navigator.pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Erro ao cadastrar.')));
      }
    }
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
                const SizedBox(height: 60),
                const Icon(Icons.app_registration, size: 80, color: Colors.green),
                const SizedBox(height: 15),
                MyTextField(
                  controller: _nameController,
                  hintText: 'Nome completo',
                  icon: const Icon(Icons.person_outline),
                  obscureText: false,
                  capitalization: true,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: const Icon(Icons.email_outlined),
                  obscureText: false,
                  capitalization: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Senha',
                  icon: const Icon(Icons.lock_outline),
                  obscureText: true,
                  capitalization: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmar senha',
                  icon: const Icon(Icons.shield_outlined),
                  obscureText: true,
                  capitalization: false,
                ),
                const SizedBox(height: 25),
                MyButton(onPressed: _handleSignUp, formKey: _formKey, text: 'Registrar'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já possui uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Faça login', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}