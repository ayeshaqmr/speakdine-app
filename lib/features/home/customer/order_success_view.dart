import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/home/customer/customer_home.dart';
import 'package:speakdine_app/features/home/customer/order_tracking_view.dart';

class OrderSuccessView extends StatelessWidget {
  final String orderId;
  const OrderSuccessView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              colorExt.primaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSuccessAnimation(),
                const SizedBox(height: 48),
                Text(
                  "Order Placed!",
                  style: GoogleFonts.outfit(
                    color: colorExt.primaryText,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 12),
                Text(
                  "Your delicious meal is on its way.\nOrder ID: #$orderId",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: colorExt.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderTrackingView(orderId: orderId)));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorExt.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: colorExt.primary.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      "TRACK MY ORDER",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CustomerHome()), (route) => false);
                  },
                  child: Text(
                    "Back to Home",
                    style: GoogleFonts.outfit(
                      color: colorExt.secondaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2000.ms, curve: Curves.easeInOut),
    ).animate().scale(curve: Curves.elasticOut, duration: 1200.ms);
  }
}
