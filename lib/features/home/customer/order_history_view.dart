import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/services/receipt_service.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  final DatabaseService _dbService = DatabaseService();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Order History", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Metropolis', color: theme.colorScheme.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _dbService.streamOrdersForCustomer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.receipt_long_outlined, size: 100, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                   const SizedBox(height: 24),
                   Text("No orders yet", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 18, fontWeight: FontWeight.w900)),
                   const SizedBox(height: 8),
                   Text("Your delicious journey starts here!", style: TextStyle(color: theme.colorScheme.outline, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
            );
          }

          var orderList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              var order = orderList[index];
              return _buildOrderCard(order, theme)
                  .animate(delay: (index * 100).ms)
                  .fadeIn()
                  .slideY(begin: 0.2);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, ThemeData theme) {
    Color statusColor = _getStatusColor(order.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order.id?.substring(0, 5).toUpperCase() ?? "NEW"}",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateFormat.format(order.createdAt),
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                _buildStatusChip(order.status, statusColor),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.restaurant_rounded, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${order.items.length} Items",
                      style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  "Rs. ${order.totalAmount.toStringAsFixed(0)}",
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButtons(order, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ReceiptService.generateAndPrintReceipt(order);
              PremiumSnackbar.show(context, message: "Generating receipt...");
            },
            icon: const Icon(Icons.receipt_rounded, size: 18),
            label: const Text("RECEIPT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
             onPressed: () {
               // Reorder logic or details
             },
             style: FilledButton.styleFrom(
               padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               backgroundColor: theme.colorScheme.primary,
             ),
             child: const Text("DETAILS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.preparing: return Colors.blue;
      case OrderStatus.ready: return Colors.teal;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }
}

