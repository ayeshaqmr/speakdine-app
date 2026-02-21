import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orders').h4().semiBold(),
              const Text('Manage incoming customer orders')
                  .muted()
                  .small(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('restaurants')
                      .doc(user?.uid)
                      .collection('orders')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildOrdersSkeleton();
                    }
                    if (snapshot.hasError) {
                      debugPrint('[RestaurantOrders] Orders stream error: ${snapshot.error}');
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
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(RadixIcons.archive,
                                size: 48,
                                color:
                                    theme.colorScheme.mutedForeground),
                            const SizedBox(height: 16),
                            const Text('No orders yet').semiBold(),
                            const SizedBox(height: 8),
                            const Text(
                                    'Orders will appear here when\ncustomers place them')
                                .muted()
                                .small(),
                          ],
                        ),
                      );
                    }
                    final orders = snapshot.data!.docs;
                    return ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index].data()
                            as Map<String, dynamic>;
                        final orderId = orders[index].id;
                        return _buildOrderCard(theme, order, orderId);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrdersSkeleton() {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Bone.text(words: 2),
                      const Bone(width: 72, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                    ],
                  ),
                  const Divider(height: 24),
                  const Bone.text(words: 3, fontSize: 12),
                  const SizedBox(height: 8),
                  const Bone.text(words: 2, fontSize: 12),
                  const SizedBox(height: 8),
                  const Bone.text(words: 1),
                  const SizedBox(height: 16),
                  const Bone(width: double.infinity, height: 36, borderRadius: BorderRadius.all(Radius.circular(8))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
      ThemeData theme, Map<String, dynamic> order, String orderId) {
    final status = order['status'] ?? 'pending';

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
              Text('Order #${orderId.substring(0, 6).toUpperCase()}')
                  .semiBold(),
              _buildStatusBadge(theme, status),
            ],
          ),
          const Divider(height: 24),
          Text('Customer: ${order['customerName'] ?? 'Unknown'}')
              .muted()
              .small(),
          const SizedBox(height: 4),
          Text('Items: ${order['itemCount'] ?? 0}').muted().small(),
          const SizedBox(height: 4),
          Text(
            '\$${order['total']?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(theme, orderId, status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
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

  Widget _buildActionButtons(
      ThemeData theme, String orderId, String status) {
    if (status == 'completed') return const SizedBox.shrink();

    String label;
    String nextStatus;
    switch (status) {
      case 'pending':
        label = 'Accept';
        nextStatus = 'preparing';
      case 'preparing':
        label = 'Mark Ready';
        nextStatus = 'ready';
      case 'ready':
        label = 'Complete';
        nextStatus = 'completed';
      default:
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        density: ButtonDensity.compact,
        onPressed: () => _updateOrderStatus(orderId, nextStatus),
        child: Text(label),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(user?.uid)
          .collection('orders')
          .doc(orderId)
          .update({'status': status});

      if (!mounted) return;
      showAppToast(context, 'Order status updated to $status');
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Something went wrong. Please try again later.');
    }
  }
}
