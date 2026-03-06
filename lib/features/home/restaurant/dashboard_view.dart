import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/home/restaurant/menu_management_view.dart';
import 'package:speakdine_app/features/home/restaurant/order_management_view.dart';
import 'package:speakdine_app/features/home/restaurant/analytics_view.dart';
import 'package:speakdine_app/features/home/restaurant/review_management_view.dart';
import 'package:speakdine_app/features/home/restaurant/add_menu_item_view.dart';
import 'package:speakdine_app/features/home/restaurant/promotions_view.dart';
import 'package:speakdine_app/features/home/restaurant/business_settings_view.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantDashboardView extends StatefulWidget {
  const RestaurantDashboardView({super.key});

  @override
  State<RestaurantDashboardView> createState() => _RestaurantDashboardViewState();
}

class _RestaurantDashboardViewState extends State<RestaurantDashboardView> {
  bool isOpen = true;
  final PageController _statsController = PageController(viewportFraction: 0.9);
  int _currentStatIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMenuItemView()));
        },
        backgroundColor: colorExt.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add New Dish", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 50),
                _buildHeader(context),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  _buildStatsCarousel(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quick Actions",
                        style: TextStyle(
                          color: colorExt.primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Metropolis',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuickAccessGrid(),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    var hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) greeting = "Good Afternoon";
    if (hour >= 17) greeting = "Good Evening";

    final user = FirebaseAuth.instance.currentUser;
    final rName = (user?.displayName != null && user!.displayName!.isNotEmpty) ? user.displayName! : "Your Restaurant";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorExt.primary.withValues(alpha: 0.1),
                child: Text(
                  rName.isNotEmpty ? rName[0].toUpperCase() : 'R',
                  style: TextStyle(color: colorExt.primary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: colorExt.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    rName,
                    style: TextStyle(
                      color: colorExt.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontFamily: 'Metropolis',
                      height: 1.1
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Icon(Icons.menu_rounded, color: colorExt.primary, size: 28),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsCarousel() {
    return StreamBuilder<List<OrderModel>>(
      stream: DatabaseService().streamOrders(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        double totalRevenue = 0;
        int activeOrders = 0;
        int ordersToday = 0;
        
        for (var order in orders) {
          totalRevenue += order.totalAmount;
          if (order.status == 'pending' || order.status == 'preparing' || order.status == 'dispatched') {
             activeOrders++;
          }
          ordersToday++; 
        }

        final List<Map<String, dynamic>> stats = [
          {
            "title": "Revenue Today",
            "value": "Rs. ${totalRevenue.toStringAsFixed(0)}",
            "trend": "+12.5%",
            "color": colorExt.primary,
            "icon": Icons.payments_rounded
          },
          {
            "title": "Orders Today",
            "value": "$ordersToday",
            "trend": "+8",
            "color": const Color(0xff5D3B1C),
            "icon": Icons.receipt_long_rounded
          },
          {
            "title": "Active Dishes",
            "value": "24",
            "trend": "Live",
            "color": const Color(0xff4D3F43),
            "icon": Icons.restaurant_menu_rounded
          },
          {
            "title": "Active Orders",
            "value": "$activeOrders",
            "trend": "Priority",
            "color": const Color(0xff8C0009),
            "icon": Icons.timer_rounded
          },
        ];

        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _statsController,
            onPageChanged: (index) => setState(() => _currentStatIndex = index),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              var stat = stats[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: stat['color'],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (stat['color'] as Color).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Icon(stat['icon'], color: Colors.white, size: 24),
                        ),
                        if (stat['trend'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2))
                            ),
                            child: Text(
                              stat['trend'], 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)
                            ),
                          )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['value'], 
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1.1)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat['title'].toString().toUpperCase(), 
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)
                        ),
                      ],
                    )
                  ],
                ),
              ).animate(target: _currentStatIndex == index ? 1 : 0).scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), duration: 200.ms);
            },
          ),
        );
      }
    );
  }

  Widget _buildQuickAccessGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildNavCard("Live Orders", "12 Active", Icons.local_fire_department_rounded, const Color(0xFFFF7043), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderManagementView()));
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildNavCard("Menu", "45 Items", Icons.restaurant_menu_rounded, const Color(0xFF7E57C2), () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuManagementView()));
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildNavCard("Analytics", "View Stats", Icons.bar_chart_rounded, const Color(0xFF26A69A), () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsView()));
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildNavCard("Reviews", "4.8 (120)", Icons.star_half_rounded, const Color(0xFFFFCA28), () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewManagementView()));
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildNavCard("Promotions", "2 Active", Icons.local_offer_rounded, const Color(0xFFE91E63), () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const PromotionsView()));
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildNavCard("Settings", "Business Setup", Icons.storefront_rounded, const Color(0xFF607D8B), () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessSettingsView()));
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildNavCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.zero,
        surfaceTintColor: color.withValues(alpha: 0.2),
        elevation: 0,
        color: colorExt.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: colorExt.secondaryText, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms);
  }
}
