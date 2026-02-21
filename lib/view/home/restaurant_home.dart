import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/view/role_select.dart';
import 'package:speak_dine/view/restaurant/menu_management.dart';
import 'package:speak_dine/view/restaurant/orders_view.dart';
import 'package:speak_dine/view/restaurant/restaurant_profile.dart';
import 'package:speak_dine/view/restaurant/qr_code_view.dart';

class RestaurantHomeView extends StatefulWidget {
  const RestaurantHomeView({super.key});

  @override
  State<RestaurantHomeView> createState() => _RestaurantHomeViewState();
}

class _RestaurantHomeViewState extends State<RestaurantHomeView> {
  String restaurantName = "Restaurant";
  int menuItemCount = 0;
  int ordersCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load restaurant info
        final doc = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            restaurantName = doc.data()?['restaurantName'] ?? 'Restaurant';
          });
        }

        // Load menu item count
        final menuSnapshot = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(user.uid)
            .collection('menu')
            .get();
        
        // Load today's orders count
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(user.uid)
            .collection('orders')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .get();

        setState(() {
          menuItemCount = menuSnapshot.docs.length;
          ordersCount = ordersSnapshot.docs.length;
        });
      }
    } catch (e) {
      print("Error loading restaurant data: $e");
    }
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SelectRoleView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colorExt.primary),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _buildWelcomeHeader(),
                  const SizedBox(height: 30),
                  
                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 30),
                  
                  // Menu Options
                  Text(
                    "Manage Your Restaurant",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorExt.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildMenuGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorExt.primary, colorExt.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorExt.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.white, size: 40),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back!",
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      restaurantName,
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.restaurant_menu,
            label: "Menu Items",
            value: menuItemCount.toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag,
            label: "Orders Today",
            value: ordersCount.toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorExt.container,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorExt.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorExt.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 14,
              color: colorExt.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildMenuOption(
          icon: Icons.menu_book_rounded,
          title: "Manage Menu",
          subtitle: "Add & edit items",
          color: Colors.orange,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuManagementView()),
            );
            // Refresh counts when returning
            _loadRestaurantData();
          },
        ),
        _buildMenuOption(
          icon: Icons.shopping_bag_rounded,
          title: "Orders",
          subtitle: "View orders",
          color: Colors.green,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersView()),
            );
            // Refresh counts when returning
            _loadRestaurantData();
          },
        ),
        _buildMenuOption(
          icon: Icons.store_rounded,
          title: "Profile",
          subtitle: "Restaurant info",
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RestaurantProfileView()),
            );
          },
        ),
        _buildMenuOption(
          icon: Icons.qr_code_rounded,
          title: "QR Code",
          subtitle: "Share menu",
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QRCodeView()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorExt.container,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorExt.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorExt.primary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 12,
                color: colorExt.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
