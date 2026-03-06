import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class CustomPopups {
  static void showRatingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RatingDialog(),
    );
  }

  static Future<void> showPremiumAlert(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Extra Large radius for 'Expressive' feel
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: colorExt.surface,
        title: Text(
          title,
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: colorExt.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: colorExt.secondaryText)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorExt.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("CONFIRM"),
          ),
        ],
      ).animate()
       .scale(
          duration: 500.ms, 
          curve: Curves.elasticOut, // Simulates shape expansion/morph
          alignment: Alignment.center
       ).fade(duration: 300.ms),
    );
  }
}

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 80, color: Colors.amber)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds),
            const SizedBox(height: 16),
            Text(
              "How was your experience?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorExt.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your feedback helps us improve SpeakDine for everyone.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorExt.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < _rating ? Colors.amber : colorExt.placeholder,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _rating == 0 ? null : () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: colorExt.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "SUBMIT FEEDBACK",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "MAYBE LATER",
                style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 300.ms).fade();
  }
}
