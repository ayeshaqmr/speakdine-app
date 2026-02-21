import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/view/restaurant/restaurant_menu_management_view.dart';
import 'package:speak_dine/view/restaurant/restaurant_order_management_view.dart';
import 'package:speak_dine/view/restaurant/restaurant_delivery_management_view.dart';

class RestaurantDashboardView extends StatefulWidget {
  const RestaurantDashboardView({super.key});

  @override
  State<RestaurantDashboardView> createState() => _RestaurantDashboardViewState();
}

class _RestaurantDashboardViewState extends State<RestaurantDashboardView> {
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: colorExt.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Restaurant Dashboard",
          style: TextStyle(
            color: colorExt.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Switch(
            value: isOpen,
            activeColor: colorExt.primary,
            onChanged: (val) {
              setState(() {
                isOpen = val;
              });
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning,\nTasty Bites!",
              style: TextStyle(
                color: colorExt.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Total Orders",
                    value: "25",
                    icon: Icons.receipt_long,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: "Pending",
                    value: "5",
                    icon: Icons.timer,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Earnings",
                    value: "Rs. 1,250",
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: "Rating",
                    value: "4.8",
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Management",
              style: TextStyle(
                color: colorExt.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            _buildNavOption(
              title: "Menu Management",
              subtitle: "Add or edit menu items",
              icon: Icons.restaurant_menu,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantMenuManagementView()));
              },
            ),
            const SizedBox(height: 15),
            _buildNavOption(
              title: "Live Orders",
              subtitle: "Manage incoming orders",
              icon: Icons.shopping_cart_checkout,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantOrderManagementView()));
              },
            ),
            const SizedBox(height: 15),
            _buildNavOption(
              title: "Delivery Management",
              subtitle: "Track drivers and deliveries",
              icon: Icons.delivery_dining,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantDeliveryManagementView()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorExt.white,
        borderRadius: BorderRadius.circular(15),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              color: colorExt.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: colorExt.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavOption({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorExt.white,
          borderRadius: BorderRadius.circular(15),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorExt.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorExt.primary, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorExt.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorExt.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorExt.secondaryText, size: 16),
          ],
        ),
      ),
    );
  }
}
