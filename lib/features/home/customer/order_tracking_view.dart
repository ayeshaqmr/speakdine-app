import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class OrderTrackingView extends StatefulWidget {
  final String orderId;
  const OrderTrackingView({super.key, required this.orderId});

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  int _currentStep = 1; // 0: Placed, 1: Preparing, 2: Dispatched, 3: Delivered

  final List<Map<String, dynamic>> _steps = [
    {"title": "Order Placed", "icon": Icons.check_circle_rounded, "time": "12:30 PM"},
    {"title": "Preparing", "icon": Icons.restaurant_rounded, "time": "12:35 PM"},
    {"title": "Dispatched", "icon": Icons.delivery_dining_rounded, "time": "Pending"},
    {"title": "Delivered", "icon": Icons.home_rounded, "time": "Pending"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Track Order #${widget.orderId.substring(0, 5).toUpperCase()}",
          style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMapPlaceholder(),
            const SizedBox(height: 32),
            _buildStatusCard(),
            const SizedBox(height: 32),
            _buildStepsList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A fake map feel
          Icon(Icons.map_rounded, size: 200, color: Colors.grey.withValues(alpha: 0.1)),
           Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining_rounded, size: 48, color: colorExt.primary).animate(onPlay: (c) => c.repeat()).moveX(begin: -50, end: 50, duration: 2.seconds, curve: Curves.easeInOut),
              const SizedBox(height: 8),
              Text("Your food is being prepared!", style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorExt.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorExt.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorExt.primary, shape: BoxShape.circle),
            child: const Icon(Icons.timer_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Estimated Arrival", style: TextStyle(color: colorExt.secondaryText, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("25 - 35 mins", style: TextStyle(color: colorExt.primaryText, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.2, curve: Curves.easeOutBack).fadeIn();
  }

  Widget _buildStepsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final isCompleted = index <= _currentStep;
          final isCurrent = index == _currentStep;

          return IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? colorExt.primary : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent ? [BoxShadow(color: colorExt.primary.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)] : [],
                      ),
                      child: isCompleted 
                        ? const Icon(Icons.check, size: 14, color: Colors.white) 
                        : null,
                    ),
                    if (index != _steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted ? colorExt.primary : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _steps[index]['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isCompleted ? FontWeight.w900 : FontWeight.w600,
                                color: isCompleted ? colorExt.primaryText : colorExt.secondaryText,
                              ),
                            ),
                            if (isCurrent)
                              Text(
                                "Now in progress...",
                                style: TextStyle(color: colorExt.primary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        Text(
                          _steps[index]['time'],
                          style: TextStyle(color: colorExt.placeholder, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: (index * 200).ms).fadeIn().slideX(begin: 0.1);
        },
      ),
    );
  }
}
