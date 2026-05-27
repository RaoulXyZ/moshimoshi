import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          color: MindBloomingColorScheme.tertiary3shadow,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 380,
                width: 380,
                child: Container(
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Benvenuta/o',
                          style: MindBloomingTextStyle.header2,
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Registrati a MoshiMoshi o effettua l'accesso se possiedi già un account!",
                            style: MindBloomingTextStyle.loginTextStrong,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 53,
                          width: 320,
                          child: MindBloomingButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "ACCEDI",
                              style: MindBloomingTextStyle.button,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 53,
                          width: 320,
                          child: MindBloomingButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "REGISTRATI",
                              style: MindBloomingTextStyle.button,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
