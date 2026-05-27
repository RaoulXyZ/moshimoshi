import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Image logo;
  @override
  SplashScreen(this.logo);

  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: Container(
                padding: const EdgeInsets.all(35),
                color: Colors.white,
                child: widget.logo,
              ),
            ),
            const SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
