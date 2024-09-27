import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:edubuddy/auth/screens/signin_screen.dart';
import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(
        '/assets/edu.png',
        width: 395.5,
        height: 650.7,
        fit: BoxFit.cover,
      ),
      duration: 300000,
      nextScreen: const SignInScreen(),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    );
  }
}
