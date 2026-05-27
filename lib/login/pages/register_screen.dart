import 'package:flutter/material.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';
import '../firebase_auth_implementation/firebase_auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  bool _isRegistering = false;
  bool _isHidden = true;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
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
                height: 500,
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
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'Ciao',
                      style: MindBloomingTextStyle.loginTextTitle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Effettua la Registrazione',
                      style: MindBloomingTextStyle.normal,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                              hintText: 'Nome',
                            ),
                            validator: (name) => name!.length < 3
                                ? 'Il nome deve contenere almeno 3 caratteri'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 140,
                          child: TextFormField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                              hintText: 'Cognome',
                            ),
                            validator: (name) => name!.length < 3
                                ? 'Il cognome deve contenere almeno 3 caratteri'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 290,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(
                            Icons.mail,
                            color: Colors.grey,
                          ),
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 290,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isHidden,
                        decoration: InputDecoration(
                          suffixIcon: togglePassword(),
                          hintText: 'Password',
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 290,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isHidden,
                        decoration: InputDecoration(
                          suffixIcon: togglePassword(),
                          hintText: 'Conferma Password',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Conferma la password';
                          }
                          if (value != _passwordController.text) {
                            return 'Le password non corrispondono';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 55,
                      width: 290,
                      child: GestureDetector(
                        child: Center(
                          child: MindBloomingButton(
                            onPressed: _register,
                            child: _isRegistering
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "REGISTRATI",
                                    style: MindBloomingTextStyle.button,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Possiedi già un Account?",
                          style: MindBloomingTextStyle.loginTextNormal,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Accedi",
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

  Widget togglePassword() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isHidden = !_isHidden;
        });
      },
      icon: _isHidden
          ? const Icon(Icons.visibility_off)
          : const Icon(
              Icons.visibility,
              color: Colors.grey,
            ),
    );
  }

  void _register() async {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa tutti i campi prima di registrarti.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      return;
    } else if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password non corrispondenti. Riprova.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      return;
    } else {
      setState(() {
        _isRegistering = true;
      });

      final result = await _auth.signUpWithEmailAndPassword(email, password);

      if (!mounted) return;

      setState(() {
        _isRegistering = false;
      });

      if (result.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrazione completata. Effettua il login.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Registrazione fallita'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
