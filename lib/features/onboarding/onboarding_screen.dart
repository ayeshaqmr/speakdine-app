import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/auth/views/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Order with voice",
      "subtitle": "Order your favorite food with your voice. Speaking your language!",
      "icon": "keyboard_voice_rounded", 
    },
    {
      "title": "Fast Delivery",
      "subtitle": "Hot food delivered to your doorstep in minutes.",
      "icon": "delivery_dining_rounded",
    },
    {
      "title": "Easy Payment",
      "subtitle": "Pay securely with JazzCash, EasyPaisa, or Cards.",
      "icon": "payments_rounded",
    },
  ];

  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, PremiumPageTransition(page: const LoginScreen()));
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: 800.ms, curve: Curves.easeInOutCubicEmphasized);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Animated Background Blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return CustomPaint(
                  painter: OrganicBackgroundPainter(
                    animationValue: _blobController.value,
                    primaryColor: colorExt.primary,
                    secondaryColor: colorExt.secondary,
                  ),
                );
              },
            ),
          ),

          // 2. Page Content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _buildPageContent(page, index, size);
            },
          ),
          
          // 3. Bottom Navigation (Skip/Next or Get Started)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: AnimatedSwitcher(
              duration: 400.ms,
              child: _currentPage == _pages.length - 1 
                ? _buildFinalCtaButtons()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: colorExt.secondaryText,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Skip",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      
                      // Progress Indicators
                      Row(
                        children: List.generate(_pages.length, (index) => _buildIndicator(index)),
                      ),

                      // Next Button
                      FilledButton(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          backgroundColor: colorExt.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: colorExt.primary.withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Next",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isCurrent = _currentPage == index;
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isCurrent ? 24 : 8,
      decoration: BoxDecoration(
        color: isCurrent ? colorExt.primary : colorExt.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPageContent(Map<String, String> page, int index, Size size) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Image Section with Floating effect
        Expanded(
          flex: 5,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(40),
            child: Icon(
              index == 0 ? Icons.keyboard_voice_rounded : 
              index == 1 ? Icons.delivery_dining_rounded : 
              Icons.payments_rounded,
              size: 180,
              color: colorExt.primary,
            )
            .animate(target: _currentPage == index ? 1 : 0)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOutBack)
            .then()
            .shake(duration: 2.seconds, curve: Curves.easeInOut)
            .then()
            .moveY(begin: 0, end: -15, duration: 2.seconds, curve: Curves.easeInOut)
            .then()
            .moveY(begin: -15, end: 0, duration: 2.seconds, curve: Curves.easeInOut), // Floating loop
          ),
        ),

        // Text Section with Glassmorphism
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 25, offset: const Offset(0, 10))
                        ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            page["title"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: colorExt.primaryText,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                          
                          const SizedBox(height: 20),
                          
                          Text(
                            page["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: colorExt.secondaryText,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalCtaButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: FilledButton(
            onPressed: _completeOnboarding,
            style: FilledButton.styleFrom(
              backgroundColor: colorExt.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: colorExt.primary.withValues(alpha: 0.3),
            ),
            child: Text(
              "GET STARTED",
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
      ],
    );
  }
}

// Custom Painter for Organic Blobs
class OrganicBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  OrganicBackgroundPainter({required this.animationValue, required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Blob 1 (Top Left - Primary)
    paint.color = primaryColor.withValues(alpha: 0.08); // Very subtle
    final path1 = Path();
    double offset1 = math.sin(animationValue * 2 * math.pi) * 20;
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(size.width * 0.5 + offset1, size.height * 0.5 + offset1, size.width, size.height * 0.2);
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    // Blob 2 (Bottom Right - Secondary)
    paint.color = secondaryColor.withValues(alpha: 0.08);
    final path2 = Path();
    double offset2 = math.cos(animationValue * 2 * math.pi) * 30;
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.5 - offset2, size.height * 0.6 - offset2, size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
    
    // Circle decorative
    paint.color = primaryColor.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.15), 60 + offset1, paint);
    
     paint.color = secondaryColor.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.85), 80 - offset2, paint);
  }

  @override
  bool shouldRepaint(covariant OrganicBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
