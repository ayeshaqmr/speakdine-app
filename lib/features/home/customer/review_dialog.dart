import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

void showReviewDialog(
  BuildContext context, {
  required String restaurantId,
  required String restaurantName,
  required String orderId,
  required String customerId,
  required String customerName,
}) {
  int selectedRating = 0;
  final commentController = TextEditingController();
  bool submitting = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: colorExt.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            'Rate your experience',
            style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurantName,
                    style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() => selectedRating = index + 1);
                          },
                          child: Icon(
                            index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: index < selectedRating ? colorExt.primary : colorExt.secondaryText.withValues(alpha: 0.4),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Comment (optional)',
                    style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: TextStyle(color: colorExt.primaryText, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: TextStyle(color: colorExt.placeholder),
                      filled: true,
                      fillColor: colorExt.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting
                  ? null
                  : () {
                      commentController.dispose();
                      Navigator.pop(ctx);
                    },
              child: Text('Cancel', style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w700)),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (selectedRating < 1) {
                        PremiumSnackbar.show(ctx, message: 'Please select a rating');
                        return;
                      }
                      setDialogState(() => submitting = true);

                      try {
                        final firestore = FirebaseFirestore.instance;

                        await firestore
                            .collection('restaurants')
                            .doc(restaurantId)
                            .collection('reviews')
                            .add({
                          'customerId': customerId,
                          'customerName': customerName,
                          'rating': selectedRating,
                          'comment': commentController.text.trim(),
                          'orderId': orderId,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        final reviewsSnapshot = await firestore
                            .collection('restaurants')
                            .doc(restaurantId)
                            .collection('reviews')
                            .get();

                        int totalRating = 0;
                        for (var doc in reviewsSnapshot.docs) {
                          final data = doc.data();
                          totalRating += (data['rating'] as int?) ?? 0;
                        }
                        final totalReviews = reviewsSnapshot.docs.length;
                        final averageRating = totalReviews > 0
                            ? totalRating / totalReviews
                            : selectedRating.toDouble();

                        await firestore
                            .collection('restaurants')
                            .doc(restaurantId)
                            .update({
                          'averageRating': averageRating,
                          'totalReviews': totalReviews,
                        });

                        await firestore
                            .collection('users')
                            .doc(customerId)
                            .collection('orders')
                            .doc(orderId)
                            .update({'reviewed': true});

                        commentController.dispose();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          PremiumSnackbar.show(context, message: 'Thank you for your review!');
                        }
                      } catch (e) {
                        debugPrint('[ReviewDialog] Error: $e');
                        setDialogState(() => submitting = false);
                        if (ctx.mounted) {
                          PremiumSnackbar.show(ctx, message: 'Something went wrong. Please try again.');
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: colorExt.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    ),
  );
}
