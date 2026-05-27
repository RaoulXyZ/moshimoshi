// lib/login/pages/login_screen.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';
import '../firebase_auth_implementation/firebase_auth_service.dart';
import 'loading_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggingIn = false;
  bool _isHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: MindBloomingColorScheme.tertiary3shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 160),
              Container(
                height: 440,
                width: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: MindBloomingColorScheme.primary
                          .withValues(alpha: 0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Text('Ciao', style: MindBloomingTextStyle.loginTextTitle),
                    const SizedBox(height: 5),
                    Text(
                      'Effettua il Login',
                      style: MindBloomingTextStyle.normal,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 290,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.check, color: Colors.grey),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 290,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isHidden,
                        decoration: InputDecoration(
                          suffixIcon: _togglePassword(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 55,
                      width: 290,
                      child: Center(
                        child: MindBloomingButton(
                          onPressed: _login,
                          child: _isLoggingIn
                              ? const CircularProgressIndicator(
                                  color: MindBloomingColorScheme.primary,
                                )
                              : Text(
                                  "ACCEDI",
                                  style: MindBloomingTextStyle.button,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Non hai ancora un account?",
                          style: MindBloomingTextStyle.loginTextNormal,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                          child: Text(
                            "Registrati",
                            style: MindBloomingTextStyle.loginTextStrong,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _togglePassword() {
    return IconButton(
      onPressed: () => setState(() => _isHidden = !_isHidden),
      icon: Icon(
        _isHidden ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
      ),
    );
  }

  void _login() async {
    setState(() => _isLoggingIn = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await _auth.signInWithEmailAndPassword(email, password);
    if (!mounted) return;

    if (result.user != null) {
      log('Logged User: ${result.user!.uid}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accesso effettuato con successo'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      setState(() => _isLoggingIn = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    } else {
      setState(() => _isLoggingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Login fallito'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
