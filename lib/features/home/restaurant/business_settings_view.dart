import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class BusinessSettingsView extends StatefulWidget {
  const BusinessSettingsView({super.key});

  @override
  State<BusinessSettingsView> createState() => _BusinessSettingsViewState();
}

class _BusinessSettingsViewState extends State<BusinessSettingsView> {
  bool _isOpen = true;
  bool _acceptingCards = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Business Settings",
          style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 22, fontFamily: 'Metropolis'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Operating Status"),
            const SizedBox(height: 16),
            _buildToggleSetting(
              title: "Accepting Orders",
              subtitle: "Turn off to temporarily hide from customer searches",
              value: _isOpen,
              onChanged: (val) => setState(() => _isOpen = val),
              icon: Icons.storefront_rounded,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Payment Configuration"),
            const SizedBox(height: 16),
            _buildToggleSetting(
              title: "Accept Credit/Debit Cards",
              subtitle: "Requires active Stripe account setup",
              value: _acceptingCards,
              onChanged: (val) => setState(() => _acceptingCards = val),
              icon: Icons.credit_card_rounded,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Delivery Zones"),
            const SizedBox(height: 16),
             ListTile(
               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
               tileColor: Colors.white,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
               leading: Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(color: colorExt.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                 child: Icon(Icons.map_rounded, color: colorExt.primary, size: 24),
               ),
               title: Text("Manage Zones", style: TextStyle(fontWeight: FontWeight.w800, color: colorExt.primaryText)),
               subtitle: Text("Configure delivery radius and fees", style: TextStyle(fontSize: 12, color: colorExt.secondaryText)),
               trailing: const Icon(Icons.chevron_right_rounded),
               onTap: () {},
             ).animate().slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(color: colorExt.primaryText, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Metropolis'),
    );
  }

  Widget _buildToggleSetting({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colorExt.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: colorExt.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: colorExt.primaryText, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: colorExt.secondaryText)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorExt.primary,
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
