import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:speakdine_app/services/firestore_service.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Order Details",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusBanner(context),
            const SizedBox(height: 24),

            // Customer Info
            _buildSectionLabel("CUSTOMER INFO"),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: colorExt.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: colorExt.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person_rounded, color: colorExt.primary, size: 28),
                ),
                title: Text(order.userName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                subtitle: const Text("Preferred Customer", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                trailing: IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Items
            _buildSectionLabel("ORDER ITEMS"),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: colorExt.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorExt.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("1x", style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, fontSize: 14)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          Text("Rs. ${item.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    )),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text("Rs. ${order.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tax & Service", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                        Text("Included", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text("Rs. ${order.totalAmount.toStringAsFixed(0)}", style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Bottom Actions
            if (order.status == OrderStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        dbService.updateOrderStatus(order.id!, OrderStatus.cancelled);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: colorExt.error),
                      child: const Text("REJECT ORDER"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        dbService.updateOrderStatus(order.id!, OrderStatus.preparing);
                        Navigator.pop(context);
                      },
                      child: const Text("ACCEPT ORDER"),
                    ),
                  ),
                ],
              )
            else if (order.status == OrderStatus.preparing)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.tonal(
                  onPressed: () {
                    dbService.updateOrderStatus(order.id!, OrderStatus.ready);
                    Navigator.pop(context);
                  },
                  child: const Text("MARK AS READY FOR PICKUP", style: TextStyle(letterSpacing: 1)),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: colorExt.primary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    Color statusColor = _getStatusColor(order.status);
    return Card(
      elevation: 0,
      color: statusColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              child: const Icon(Icons.timer_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const Text("Expected in 20-30 mins", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Color _getStatusColor(OrderStatus status) {
    switch(status) {
      case OrderStatus.pending: return Colors.orange[800]!;
      case OrderStatus.preparing: return const Color(0xff922052);
      case OrderStatus.ready: return Colors.green[700]!;
      case OrderStatus.delivered: return Colors.grey[600]!;
      case OrderStatus.cancelled: return Colors.red[700]!;
    }
  }
}
