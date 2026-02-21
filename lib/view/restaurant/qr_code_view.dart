import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_dine/common/colorExtension.dart';

class QRCodeView extends StatelessWidget {
  const QRCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final restaurantId = user?.uid ?? 'unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QR Code",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Code Placeholder
              Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorExt.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 150,
                      color: colorExt.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      restaurantId.substring(0, 8).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorExt.primaryText,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text(
                "Your Restaurant QR Code",
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colorExt.primary,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "Customers can scan this code to\nview your menu on their phone",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 16,
                  color: colorExt.primaryText,
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.download,
                    label: "Save",
                    color: colorExt.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("QR Code saved! (Feature coming soon)"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.share,
                    label: "Share",
                    color: colorExt.secondary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Share feature coming soon!"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.print,
                    label: "Print",
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Print feature coming soon!"),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorExt.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorExt.primary),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Display this QR code at your restaurant entrance or on tables for easy menu access.",
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          color: colorExt.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

