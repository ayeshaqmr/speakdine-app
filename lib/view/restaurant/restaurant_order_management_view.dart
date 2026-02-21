import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/models/menu_item.dart';
import 'package:speak_dine/models/order_model.dart';

class RestaurantOrderManagementView extends StatefulWidget {
  const RestaurantOrderManagementView({super.key});

  @override
  State<RestaurantOrderManagementView> createState() => _RestaurantOrderManagementViewState();
}

class _RestaurantOrderManagementViewState extends State<RestaurantOrderManagementView> {
  List<OrderModel> orders = [
    OrderModel(
      id: "ORD-001",
      userId: "u1",
      userName: "John Doe",
      items: [
        MenuItemModel(name: "Burger", description: "", price: 9.99),
        MenuItemModel(name: "Fries", description: "", price: 4.50),
      ],
      totalAmount: 14.49,
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    OrderModel(
      id: "ORD-002",
      userId: "u2",
      userName: "Jane Smith",
      items: [
        MenuItemModel(name: "Coca Cola", description: "", price: 2.50),
      ],
      totalAmount: 2.50,
      status: OrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(
          "Lives Orders",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: colorExt.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorExt.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          var order = orders[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorExt.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
                      order.id ?? "Unknown",
                      style: TextStyle(
                        color: colorExt.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _buildStatusChip(order),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Customer: ${order.userName}",
                  style: TextStyle(
                    color: colorExt.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const Divider(height: 30),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: colorExt.textfield,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text("1x", style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Text(item.name, style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text("Rs. ${item.price.toStringAsFixed(0)}", style: TextStyle(color: colorExt.primaryText)),
                        ],
                      ),
                    )).toList(),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        color: colorExt.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Rs. ${order.totalAmount.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: colorExt.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorExt.secondaryText,
                          side: BorderSide(color: colorExt.secondaryText),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Decline"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _advanceStatus(order);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorExt.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          _getNextActionText(order.status),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _advanceStatus(OrderModel order) {
    setState(() {
      if (order.status == OrderStatus.pending) {
        order.status = OrderStatus.preparing;
      } else if (order.status == OrderStatus.preparing) {
        order.status = OrderStatus.ready;
      } else if (order.status == OrderStatus.ready) {
        order.status = OrderStatus.delivered;
      }
    });
  }

  String _getNextActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Accept";
      case OrderStatus.preparing:
        return "Mark Ready";
      case OrderStatus.ready:
        return "Order Picked Up";
      case OrderStatus.delivered:
        return "Completed";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  Widget _buildStatusChip(OrderModel order) {
    Color bg = Colors.grey;
    Color text = Colors.white;
    String label = order.status.toString().split('.').last.toUpperCase();
    switch (order.status) {
      case OrderStatus.pending:
        bg = Colors.orangeAccent;
        break;
      case OrderStatus.preparing:
        bg = Colors.blueAccent;
        break;
      case OrderStatus.ready:
        bg = Colors.green;
        break;
      case OrderStatus.delivered:
        bg = Colors.grey;
        break;
      case OrderStatus.cancelled:
        bg = Colors.redAccent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
