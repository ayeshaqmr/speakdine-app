import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:speak_dine/firebase_options.dart';
import 'package:speak_dine/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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