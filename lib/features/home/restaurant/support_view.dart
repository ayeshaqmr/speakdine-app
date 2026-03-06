import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class RestaurantSupportView extends StatelessWidget {
  const RestaurantSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Merchant Support", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Metropolis', color: colorExt.primaryText)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildEmergencyCard(),
             const SizedBox(height: 32),
             Text("Support Channels", style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
             const SizedBox(height: 16),
             _buildChannelTile("Merchant Help Center", Icons.menu_book_rounded, "Guides on using the platform", () {}),
             _buildChannelTile("Payout Issues", Icons.account_balance_wallet_rounded, "Resolution for payment delays", () {}),
             _buildChannelTile("Order Disputes", Icons.report_problem_rounded, "Report issues with specific orders", () {}),
             _buildChannelTile("Tech Support", Icons.biotech_rounded, "Report app bugs or hardware issues", () {}),
             const SizedBox(height: 40),
             _buildEmailSupport(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorExt.primary, colorExt.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: colorExt.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          const Text(
            "Live Merchant Support",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Metropolis'),
          ),
          const SizedBox(height: 8),
          const Text(
            "Connect with a merchant specialist for immediate assistance with active orders.",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorExt.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("START LIVE CHAT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildChannelTile(String title, IconData icon, String description, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: colorExt.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: colorExt.primary, size: 24),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colorExt.primaryText)),
      subtitle: Text(description, style: TextStyle(fontSize: 12, color: colorExt.secondaryText, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded, color: colorExt.placeholder, size: 20),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  Widget _buildEmailSupport() {
    return Center(
      child: Column(
        children: [
          Text("Prefer email?", style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            "merchants@speakdine.com",
            style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
