import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';

class RestaurantDeliveryManagementView extends StatefulWidget {
  const RestaurantDeliveryManagementView({super.key});

  @override
  State<RestaurantDeliveryManagementView> createState() => _RestaurantDeliveryManagementViewState();
}

class _RestaurantDeliveryManagementViewState extends State<RestaurantDeliveryManagementView> {
  final List<Map<String, dynamic>> deliveries = [
    {"id": "DEL-1023", "driver": "Mike Ross", "status": "On the way", "eta": "15 mins", "orderId": "ORD-001"},
    {"id": "DEL-1024", "driver": "Rachel Zane", "status": "Picking up", "eta": "5 mins", "orderId": "ORD-002"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(
          "Delivery Status",
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
        itemCount: deliveries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          var delivery = deliveries[index];
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delivery_dining, color: Colors.blue[700]),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery['driver'],
                        style: TextStyle(
                          color: colorExt.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Order: ${delivery['orderId']}",
                        style: TextStyle(
                          color: colorExt.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      delivery['status'],
                      style: TextStyle(
                        color: colorExt.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      delivery['eta'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
}
