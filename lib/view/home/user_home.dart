import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/view/role_select.dart';
import 'package:speak_dine/view/user/restaurant_detail.dart';
import 'package:speak_dine/view/user/cart_view.dart';
import 'package:speak_dine/services/cart_service.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = "Customer";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Customer';
        });
      }
    }
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
          "SpeakDine",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
        actions: [
          // Cart Button
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: colorExt.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartView()),
                  ).then((_) => setState(() {})); // Refresh on return
                },
              ),
              if (cartService.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartService.totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout, color: colorExt.primary),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorExt.primary, colorExt.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $userName! 👋",
                  style: const TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "What would you like to eat today?",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Restaurants Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Restaurants Near You",
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorExt.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Restaurant List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('restaurants').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 80, color: colorExt.shadow),
                        const SizedBox(height: 20),
                        Text(
                          "No restaurants available",
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 18,
                            color: colorExt.primaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final restaurants = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index].data() as Map<String, dynamic>;
                    final restaurantId = restaurants[index].id;

                    return _buildRestaurantCard(restaurant, restaurantId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant, String restaurantId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailView(
              restaurantId: restaurantId,
              restaurantName: restaurant['restaurantName'] ?? 'Restaurant',
            ),
          ),
        ).then((_) => setState(() {})); // Refresh cart count on return
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
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
        child: Row(
          children: [
            // Restaurant Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: colorExt.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.restaurant,
                color: colorExt.primary,
                size: 35,
              ),
            ),
            const SizedBox(width: 15),

            // Restaurant Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['restaurantName'] ?? 'Restaurant',
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorExt.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colorExt.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant['address'] ?? 'No address',
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 13,
                            color: colorExt.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: colorExt.secondary),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['phone'] ?? 'No phone',
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 13,
                          color: colorExt.primaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right, color: colorExt.primary, size: 30),
          ],
        ),
      ),
    );
  }
}
