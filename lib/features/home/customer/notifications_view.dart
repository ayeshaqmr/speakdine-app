import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "Order Delivered",
      "body": "Your order from Tasty Bites has been delivered. Enjoy your meal!",
      "time": "2 hours ago",
      "icon": Icons.check_circle_rounded,
      "color": Colors.green,
      "isRead": false
    },
    {
      "title": "Order Confirmed",
      "body": "Burger King has confirmed your order. Estimated delivery in 20 mins.",
      "time": "5 hours ago",
      "icon": Icons.shopping_bag_rounded,
      "color": Colors.blue,
      "isRead": true
    },
    {
      "title": "Weekend Offer!",
      "body": "Get 20% off on all pizza orders this weekend. Limited time!",
      "time": "1 day ago",
      "icon": Icons.local_offer_rounded,
      "color": Colors.orange,
      "isRead": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Metropolis', color: theme.colorScheme.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _notifications.isEmpty ? _buildEmptyState(theme) : _buildNotificationList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 100, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text("No notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildNotificationList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        var notif = _notifications[index];
        return _buildNotificationItem(notif, theme)
            .animate(delay: (index * 100).ms)
            .fadeIn()
            .slideX(begin: 0.1);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif, ThemeData theme) {
    bool isRead = notif["isRead"] ?? true;
    Color notifColor = notif["color"] as Color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRead ? theme.colorScheme.surface : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRead ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5) : theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: notifColor.withValues(alpha: 0.1),
              shape: BoxShape.circle
            ),
            child: Icon(notif["icon"], color: notifColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif["title"],
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.w700 : FontWeight.w900
                      ),
                    ),
                    Text(
                      notif["time"],
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notif["body"],
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

