import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class QRCodeView extends StatelessWidget {
  const QRCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final restaurantId = user?.uid ?? 'unknown';

    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          'QR Code',
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share this with your customers',
                  style: TextStyle(color: colorExt.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Card(
              elevation: 8,
              shadowColor: colorExt.primary.withValues(alpha: 0.2),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 160,
                      color: colorExt.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      restaurantId.substring(0, 8).toUpperCase(),
                      style: TextStyle(
                        letterSpacing: 4,
                        color: colorExt.secondaryText.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Your Restaurant QR Code',
              style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Customers can scan this code to\nview your menu on their phone',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorExt.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  Icons.save_alt_rounded,
                  'Save',
                  () {
                    PremiumSnackbar.show(context, message: 'Save feature coming soon');
                  },
                ),
                const SizedBox(width: 48),
                _buildActionButton(
                  context,
                  Icons.share_rounded,
                  'Share',
                  () {
                    PremiumSnackbar.show(context, message: 'Share feature coming soon');
                  },
                ),
              ],
            ),
            const SizedBox(height: 56),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorExt.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorExt.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 24, color: colorExt.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Display this QR code at your restaurant entrance or on tables for easy menu access.',
                      style: TextStyle(color: colorExt.secondaryText, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorExt.surfaceContainerLow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: colorExt.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
