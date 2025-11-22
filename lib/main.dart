import 'package:flutter/material.dart';
import 'view/splash_screen.dart';

void main() {
  runApp(const SpeakDine());
}
class SpeakDine extends StatelessWidget {
  const SpeakDine({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",


      ),
      home: const SplashView(),
    );
  }
}