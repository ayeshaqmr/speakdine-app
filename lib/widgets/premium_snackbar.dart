import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class PremiumSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    bool isError = false,
  }) {
    Flushbar(
      title: title,
      message: message,
      titleColor: Colors.white,
      messageColor: Colors.white.withValues(alpha: 0.9),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: isError 
          ? colorExt.error 
          : const Color(0xFF313033), // Inverse Surface (M3 Dark)
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(0, 4),
          blurRadius: 10,
        )
      ],
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? Colors.white : const Color(0xFFD0BCFF), // Primary Light/Inverse Primary
        size: 24,
      ),
      mainButton: TextButton(
        onPressed: () {
          // Note: using the context from the call site to pop if needed, 
          // but Flushbar handles its own dismissal usually.
        },
        child: Text(
          "DISMISS",
          style: TextStyle(
            color: isError ? Colors.white : const Color(0xFFD0BCFF),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ).show(context);
  }
}
