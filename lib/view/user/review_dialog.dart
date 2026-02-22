
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/utils/toast_helper.dart';

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
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Rate your experience'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurantName).semiBold(),
                  const SizedBox(height: 20),
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
                            RadixIcons.star,
                            color: index < selectedRating
                                ? theme.colorScheme.primary
                                : theme.colorScheme.mutedForeground,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  const Text('Comment (optional)').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                    controller: commentController,
                    placeholder: const Text('Share your experience...'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: submitting
                  ? null
                  : () {
                      commentController.dispose();
                      Navigator.pop(ctx);
                    },
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (selectedRating < 1) {
                        showAppToast(ctx, 'Please select a rating');
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
                          showAppToast(context, 'Thank you for your review!');
                        }
                      } catch (e) {
                        debugPrint('[ReviewDialog] Error: $e');
                        setDialogState(() => submitting = false);
                        if (ctx.mounted) {
                          showAppToast(
                              ctx, 'Something went wrong. Please try again.');
                        }
                      }
                    },
              child: submitting
                  ? const Text('Submitting...')
                  : const Text('Submit'),
            ),
          ],
        );
      },
    ),
  );
}
