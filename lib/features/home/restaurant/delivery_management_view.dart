import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class DeliveryManagementView extends StatefulWidget {
  const DeliveryManagementView({super.key});

  @override
  State<DeliveryManagementView> createState() => _DeliveryManagementViewState();
}

class _DeliveryManagementViewState extends State<DeliveryManagementView> {
  final List<Map<String, dynamic>> deliveries = [
    {
      "id": "DEL-1023",
      "driver": "Mike Ross",
      "status": "On the way",
      "eta": "15 mins",
      "orderId": "ORD-001"
    },
    {
      "id": "DEL-1024",
      "driver": "Rachel Zane",
      "status": "Picking up",
      "eta": "5 mins",
      "orderId": "ORD-002"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Delivery Status",
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          var delivery = deliveries[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            color: colorExt.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorExt.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delivery_dining_rounded, color: colorExt.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery['driver'],
                          style: TextStyle(
                            color: colorExt.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Order: ${delivery['orderId']}",
                          style: TextStyle(
                            color: colorExt.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorExt.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          delivery['status'].toUpperCase(),
                          style: TextStyle(
                            color: colorExt.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: colorExt.secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            delivery['eta'],
                            style: TextStyle(
                              color: colorExt.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.1);
        },
      ),
    );
  }
}
