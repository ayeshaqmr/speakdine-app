import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/services/cart_service.dart';
import 'package:speak_dine/view/user/cart_view.dart';

class RestaurantDetailView extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantDetailView({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addToCart(Map<String, dynamic> item, String itemId) {
    setState(() {
      cartService.addItem(widget.restaurantId, widget.restaurantName, item, itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item['name']} added to cart!"),
        backgroundColor: colorExt.primary,
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: "View Cart",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartView()),
            ).then((_) => setState(() {}));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurantName,
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
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
                  ).then((_) => setState(() {}));
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Header
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
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurantName,
                        style: const TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Browse our menu",
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Menu",
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colorExt.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Menu Items
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('restaurants')
                  .doc(widget.restaurantId)
                  .collection('menu')
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
                        Icon(Icons.menu_book_outlined, size: 80, color: colorExt.shadow),
                        const SizedBox(height: 20),
                        Text(
                          "No menu items available",
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

                final items = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index].data() as Map<String, dynamic>;
                    final itemId = items[index].id;

                    return _buildMenuItem(item, itemId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, String itemId) {
    final quantityInCart = cartService.getItemQuantity(widget.restaurantId, itemId);

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
      child: Row(
        children: [
          // Food Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorExt.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fastfood_rounded, color: colorExt.primary, size: 30),
          ),
          const SizedBox(width: 15),

          // Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Item',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorExt.primary,
                  ),
                ),
                if (item['description'] != null && item['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item['description'],
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 13,
                        color: colorExt.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  "\$${item['price']?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorExt.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Add Button
          Column(
            children: [
              if (quantityInCart > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorExt.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "x$quantityInCart",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () => _addToCart(item, itemId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorExt.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                ),
                child: const Text(
                  "Add",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
