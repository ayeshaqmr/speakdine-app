import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orders",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('restaurants')
            .doc(user?.uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: colorExt.shadow,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No orders yet",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorExt.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Orders will appear here when\ncustomers place them",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 16,
                      color: colorExt.shadow,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;

              return _buildOrderCard(order, orderId);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String orderId) {
    final status = order['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorExt.container,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorExt.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${orderId.substring(0, 6).toUpperCase()}",
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorExt.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            "Customer: ${order['customerName'] ?? 'Unknown'}",
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: colorExt.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Items: ${order['itemCount'] ?? 0}",
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: colorExt.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Total: \$${order['total']?.toStringAsFixed(2) ?? '0.00'}",
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorExt.secondary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              if (status == 'pending')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(orderId, 'preparing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Accept", style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (status == 'preparing') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(orderId, 'ready'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Ready", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
              if (status == 'ready')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(orderId, 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorExt.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Complete", style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return colorExt.primary;
      default:
        return colorExt.primaryText;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(user?.uid)
          .collection('orders')
          .doc(orderId)
          .update({'status': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order status updated to $status"),
          backgroundColor: colorExt.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

