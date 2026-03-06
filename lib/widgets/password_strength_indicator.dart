import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

/// Calculates password strength (0–4) based on criteria:
/// - Length >= 8
/// - Uppercase letter
/// - Number
/// - Special character
int calcPasswordStrength(String password) {
  int score = 0;
  if (password.length >= 8) score++;
  if (password.contains(RegExp(r'[A-Z]'))) score++;
  if (password.contains(RegExp(r'[0-9]'))) score++;
  if (password.contains(RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:,.<>?/\\|`]'))) score++;
  return score;
}

/// Returns a validation error string if the password doesn't meet requirements.
/// Returns null if the password is valid.
String? validatePasswordStrength(String? password) {
  if (password == null || password.isEmpty) return "Password is required";
  if (password.length < 8) return "At least 8 characters";
  if (!password.contains(RegExp(r'[A-Z]'))) return "Add at least 1 uppercase letter (A-Z)";
  if (!password.contains(RegExp(r'[0-9]'))) return "Add at least 1 number (0-9)";
  if (!password.contains(RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:,.<>?/\\|`]'))) {
    return "Add at least 1 special character (!@#\$...)";
  }
  return null;
}

class PasswordStrengthIndicator extends StatelessWidget {
  final TextEditingController controller;
  
  const PasswordStrengthIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final password = value.text;
        if (password.isEmpty) return const SizedBox.shrink();
        
        final strength = calcPasswordStrength(password);
        
        final strengthLabels = ["Very Weak", "Weak", "Fair", "Strong", "Very Strong"];
        final strengthColors = [
          Colors.red.shade700,
          Colors.orange.shade700,
          Colors.amber.shade700,
          Colors.lightGreen.shade700,
          Colors.green.shade700,
        ];

        final label = strengthLabels[strength];
        final color = strengthColors[strength];

        final checks = [
          _PasswordCheck(label: "8+ characters", passed: password.length >= 8),
          _PasswordCheck(label: "Uppercase letter (A-Z)", passed: password.contains(RegExp(r'[A-Z]'))),
          _PasswordCheck(label: "Number (0-9)", passed: password.contains(RegExp(r'[0-9]'))),
          _PasswordCheck(label: "Special character (!@#\$...)", passed: password.contains(RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:,.<>?/\\|`]'))),
        ];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Strength bar row
              Row(
                children: [
                  ...List.generate(4, (index) {
                    final filled = index < strength;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 5,
                        margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: filled ? color : colorExt.placeholder.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Checklist
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: checks.map((c) => _buildCheck(c)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheck(_PasswordCheck check) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            check.passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            key: ValueKey(check.passed),
            color: check.passed ? Colors.green : colorExt.placeholder,
            size: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          check.label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: check.passed ? Colors.green.shade700 : colorExt.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _PasswordCheck {
  final String label;
  final bool passed;
  const _PasswordCheck({required this.label, required this.passed});
}
