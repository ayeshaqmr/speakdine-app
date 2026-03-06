import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/home/restaurant/order_details_view.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class OrderManagementView extends StatefulWidget {
  const OrderManagementView({super.key});

  @override
  State<OrderManagementView> createState() => _OrderManagementViewState();
}

class _OrderManagementViewState extends State<OrderManagementView> with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        title: Text(
          "Kitchen Board",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorExt.primary,
          unselectedLabelColor: colorExt.secondaryText,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          indicatorColor: colorExt.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "New"),
            Tab(text: "Preparing"),
            Tab(text: "Ready"),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _dbService.streamOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          var allOrders = snapshot.data ?? [];
          
          var newOrders = allOrders.where((o) => o.status == OrderStatus.pending).toList();
          var preparingOrders = allOrders.where((o) => o.status == OrderStatus.preparing).toList();
          var readyOrders = allOrders.where((o) => o.status == OrderStatus.ready || o.status == OrderStatus.delivered).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(newOrders, OrderStatus.pending),
              _buildOrderList(preparingOrders, OrderStatus.preparing),
              _buildOrderList(readyOrders, OrderStatus.ready),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _dbService.createDummyOrder();
          if(mounted) PremiumSnackbar.show(context, message: "New test order created!");
        },
        backgroundColor: colorExt.primaryContainer,
        foregroundColor: colorExt.primary,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("Simulate Order", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, OrderStatus status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 80, color: colorExt.placeholder.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              "No orders here",
              style: TextStyle(color: colorExt.secondaryText, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderTicket(orders[index], index).animate(delay: (index * 100).ms).slideX(begin: 0.1, curve: Curves.easeOutBack);
      },
    );
  }

  Widget _buildOrderTicket(OrderModel order, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorExt.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header (Status Chip Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: _getStatusColor(order.status), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "#${(order.id ?? "").substring(0, 8).toUpperCase()}",
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorExt.secondaryContainer,
                      radius: 18,
                      child: Icon(Icons.person_rounded, size: 20, color: colorExt.secondaryText),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.userName,
                            style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          Text(
                            "Order placed at 12:30 PM", 
                            style: TextStyle(color: colorExt.secondaryText, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Items
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        "1x", 
                        style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, fontSize: 14)
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w700, fontSize: 15)
                        ),
                      ),
                    ],
                  ),
                )),
                
                if (order.items.length > 2)
                  Text(
                    "+ ${order.items.length - 2} more items",
                    style: TextStyle(color: colorExt.secondaryText, fontSize: 13, fontStyle: FontStyle.italic),
                  ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount", style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w700)),
                    Text(
                      "Rs. ${order.totalAmount.toStringAsFixed(0)}", 
                      style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 20)
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Hierarchical Actions
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsView(order: order)));
                      },
                      child: const Text("Details"),
                    ),
                    const Spacer(),
                    if (order.status == OrderStatus.pending) ...[
                      OutlinedButton(
                        onPressed: () => _updateStatus(order, OrderStatus.cancelled),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorExt.error, 
                          side: BorderSide(color: colorExt.error),
                        ),
                        child: const Text("Reject"),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _updateStatus(order, OrderStatus.preparing),
                        child: const Text("Accept"),
                      ),
                    ] else if (order.status == OrderStatus.preparing) ...[
                      FilledButton.tonal(
                        onPressed: () => _updateStatus(order, OrderStatus.ready),
                        child: const Text("Ready for Pickup"),
                      ),
                    ] else if (order.status == OrderStatus.ready) ...[
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                      const SizedBox(width: 8),
                      const Text("READY", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900)),
                    ]
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch(status) {
      case OrderStatus.pending: return Colors.orange[800]!;
      case OrderStatus.preparing: return colorExt.primary;
      case OrderStatus.ready: return Colors.green[700]!;
      case OrderStatus.delivered: return Colors.grey[600]!;
      case OrderStatus.cancelled: return colorExt.error;
    }
  }

  void _updateStatus(OrderModel order, OrderStatus nextStatus) {
    _dbService.updateOrderStatus(order.id!, nextStatus);
    PremiumSnackbar.show(context, message: "Order #${(order.id ?? "").substring(0, 5)} updated");
  }
}
