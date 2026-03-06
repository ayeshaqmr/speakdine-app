import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReviewManagementView extends StatefulWidget {
  const ReviewManagementView({super.key});

  @override
  State<ReviewManagementView> createState() => _ReviewManagementViewState();
}

class _ReviewManagementViewState extends State<ReviewManagementView> {
  final DatabaseService _dbService = DatabaseService();
  final String _restaurantId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController _replyController = TextEditingController();

  void _showReplyDialog(String reviewId) {
    _replyController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reply to Review", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _replyController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Type your response here...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          FilledButton(
            onPressed: () async {
              if (_replyController.text.trim().isEmpty) return;
              await _dbService.addReplyToReview(_restaurantId, reviewId, _replyController.text.trim());
              if (mounted) {
                Navigator.pop(context);
                PremiumSnackbar.show(context, message: "Reply sent successfully!");
              }
            },
            child: const Text("SEND REPLY"),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "Unknown Date";
    if (date is! DateTime) {
       date = date.toDate(); // Assuming Timestamp from Firestore
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Customer Reviews",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: _restaurantId.isEmpty 
        ? const Center(child: Text("Error: Not logged in"))
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: _dbService.streamReviewsForRestaurant(_restaurantId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No reviews found.", style: TextStyle(fontSize: 16)));
              }

              final reviews = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  final isReplied = review['reply'] != null && review['reply'].toString().isNotEmpty;
                  final customerName = review['customerName'] ?? "Anonymous";
                  final rating = (review['rating'] ?? 0).toInt();
                  final comment = review['comment'] ?? "";

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: colorExt.surfaceContainerLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: colorExt.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                                      style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(customerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                ],
                              ),
                              Text(_formatDate(review['createdAt']), style: TextStyle(color: colorExt.secondaryText, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star_rounded, 
                              size: 20, 
                              color: i < rating ? Colors.amber : colorExt.outlineVariant.withValues(alpha: 0.5)
                            )),
                          ),
                          const SizedBox(height: 12),
                          if (comment.isNotEmpty) ...[
                            Text(
                              comment,
                              style: TextStyle(color: colorExt.primaryText, height: 1.5, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: isReplied 
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Your Reply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                          const SizedBox(height: 4),
                                          Text(review['reply'], style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    )
                                  : FilledButton.tonal(
                                      onPressed: () => _showReplyDialog(review['id']),
                                      child: const Text("REPLY TO REVIEW"),
                                    ),
                              ),
                              if (!isReplied) ...[
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: () {},
                                  icon: const Icon(Icons.flag_rounded, size: 20),
                                  style: IconButton.styleFrom(foregroundColor: colorExt.error),
                                )
                              ]
                            ],
                          )
                        ],
                      ),
                    ),
                  ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.1);
                },
              );
            },
          ),
    );
  }
}
