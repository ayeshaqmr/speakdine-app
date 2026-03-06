import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakdine_app/features/onboarding/onboarding_screen.dart';
import 'package:speakdine_app/features/auth/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (onboardingCompleted) {
       Navigator.pushReplacement(context, _createRoute(const LoginScreen()));
    } else {
       Navigator.pushReplacement(context, _createRoute(const OnboardingScreen()));
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      body: Stack(
        children: [
          // Background image with subtle zoom & blur
          SizedBox.expand(
            child: Image.asset(
              "assets/splash.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: colorExt.surface),
            )
            .animate()
            .fadeIn(duration: 1.seconds)
            .scale(
              begin: const Offset(1.1, 1.1), 
              end: const Offset(1.0, 1.0), 
              duration: 3.seconds, 
              curve: Curves.easeOutCubic
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                   colorExt.surface.withValues(alpha: 0.2),
                   colorExt.surface.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // Centered logo and text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  "assets/icons/speakdine_logo.png",
                  width: 200,
                  height: 200,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.restaurant_rounded,
                    size: 120,
                    color: colorExt.primary,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .shimmer(delay: 1.seconds, duration: 2.seconds, color: Colors.white.withValues(alpha: 0.4)),
                
                const SizedBox(height: 16),
                
                // SPEAK DINE text
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "SPEAK ",
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: colorExt.primary,
                          letterSpacing: 4,
                        ),
                      ),
                      TextSpan(
                        text: "DINE",
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          color: colorExt.primary,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                
                const SizedBox(height: 8),
                Text(
                  "ELEVATE YOUR DINING EXPERIENCE",
                  style: GoogleFonts.outfit(
                    color: colorExt.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 1.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}