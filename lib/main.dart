import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(const SpeakDine());
}

class SpeakDine extends StatelessWidget {
  const SpeakDine({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SPEAK DINE',
          theme: ThemeService().themeData,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          builder: (context, widget) {
            // Global Responsive Wrapper
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
                    right: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
                  )
                ),
                child: widget!,
              ),
            );
          },
        );
      },
    );
  }
}
