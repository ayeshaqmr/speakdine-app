import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/utils/toast_helper.dart';

class CustomerOrdersView extends StatelessWidget {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Orders').h4().semiBold(),
              const Text('Track and review your past orders')
                  .muted()
                  .small(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSkeleton();
              }
              if (snapshot.hasError) {
                debugPrint('[CustomerOrders] Orders stream error: ${snapshot.error}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    showAppToast(context, 'Unable to load orders. Please try again.');
                  }
                });
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.crossCircled,
                          size: 48,
                          color: theme.colorScheme.destructive),
                      const SizedBox(height: 16),
                      const Text('Unable to load orders').semiBold(),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.archive,
                          size: 48,
                          color: theme.colorScheme.mutedForeground),
                      const SizedBox(height: 16),
                      const Text('No orders yet').semiBold(),
                      const SizedBox(height: 8),
                      const Text('Your order history will appear here')
                          .muted()
                          .small(),
                    ],
                  ),
                );
              }
              final orders = snapshot.data!.docs;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order =
                      orders[index].data() as Map<String, dynamic>;
                  return _buildOrderCard(theme, order);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Bone.text(words: 2),
                  const SizedBox(height: 8),
                  const Bone.text(words: 3, fontSize: 12),
                  const SizedBox(height: 8),
                  const Bone.text(words: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final restaurantName = order['restaurantName'] ?? 'Restaurant';
    final itemCount = order['itemCount'] ?? 0;
    final total = order['total']?.toStringAsFixed(2) ?? '0.00';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(restaurantName).semiBold(),
              ),
              _buildStatusChip(theme, status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(RadixIcons.archive,
                  size: 14, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 6),
              Text('$itemCount items').muted().small(),
              const Spacer(),
              Text(
                '\$$total',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'pending':
        bgColor = Colors.orange.withAlpha(30);
        textColor = Colors.orange;
      case 'preparing':
        bgColor = Colors.blue.withAlpha(30);
        textColor = Colors.blue;
      case 'ready':
        bgColor = Colors.green.withAlpha(30);
        textColor = Colors.green;
      case 'completed':
        bgColor = theme.colorScheme.primary.withAlpha(30);
        textColor = theme.colorScheme.primary;
      default:
        bgColor = theme.colorScheme.muted;
        textColor = theme.colorScheme.mutedForeground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
