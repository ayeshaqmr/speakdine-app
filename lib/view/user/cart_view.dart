import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/services/cart_service.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _placingOrder = false;

  void _increaseQuantity(String restaurantId, int index) {
    setState(() {
      cartService.increaseQuantity(restaurantId, index);
    });
  }

  void _decreaseQuantity(String restaurantId, int index) {
    setState(() {
      cartService.decreaseQuantity(restaurantId, index);
    });
  }

  void _removeItem(String restaurantId, int index) {
    setState(() {
      cartService.removeItem(restaurantId, index);
    });
  }

  Future<void> _placeOrder() async {
    if (cartService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _placingOrder = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Get user details
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final customerName = userData['name'] ?? 'Customer';
      final customerPhone = userData['phone'] ?? '';
      final customerEmail = userData['email'] ?? user.email ?? '';

      // Place order for each restaurant
      for (var entry in cartService.cart.entries) {
        final restaurantId = entry.key;
        final items = entry.value;

        // Calculate total for this restaurant
        double restaurantTotal = 0;
        int totalQuantity = 0;
        List<Map<String, dynamic>> orderItems = [];
        
        for (var item in items) {
          final quantity = item['quantity'] ?? 1;
          final itemTotal = (item['price'] ?? 0) * quantity;
          restaurantTotal += itemTotal;
          totalQuantity += quantity as int;
          orderItems.add({
            'itemId': item['itemId'],
            'name': item['name'],
            'price': item['price'],
            'quantity': quantity,
            'itemTotal': itemTotal,
          });
        }

        // Create order in restaurant's orders collection
        await _firestore
            .collection('restaurants')
            .doc(restaurantId)
            .collection('orders')
            .add({
          'customerId': user.uid,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerEmail': customerEmail,
          'items': orderItems,
          'itemCount': totalQuantity,
          'total': restaurantTotal,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Also save to user's order history
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .add({
          'restaurantId': restaurantId,
          'restaurantName': items.first['restaurantName'] ?? 'Restaurant',
          'items': orderItems,
          'itemCount': totalQuantity,
          'total': restaurantTotal,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Clear cart
      setState(() {
        cartService.clearCart();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Order placed successfully! 🎉"),
          backgroundColor: colorExt.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      // Go back to home
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error placing order: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _placingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Cart",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
        actions: [
          if (cartService.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Clear Cart?"),
                    content: const Text("Remove all items from your cart?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            cartService.clearCart();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Clear", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "Clear",
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cartService.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Cart Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(15),
                    children: cartService.cart.entries.map((entry) {
                      final restaurantId = entry.key;
                      final items = entry.value;
                      final restaurantName = items.isNotEmpty
                          ? items.first['restaurantName'] ?? 'Restaurant'
                          : 'Restaurant';

                      return _buildRestaurantSection(restaurantId, restaurantName, items);
                    }).toList(),
                  ),
                ),

                // Order Summary
                _buildOrderSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: colorExt.shadow,
          ),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colorExt.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some delicious food!",
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 16,
              color: colorExt.shadow,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorExt.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Browse Restaurants",
              style: TextStyle(
                fontFamily: 'Metropolis',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(String restaurantId, String restaurantName, List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Header
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: colorExt.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant, color: colorExt.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    restaurantName,
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorExt.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildCartItem(restaurantId, index, item);
          }),
        ],
      ),
    );
  }

  Widget _buildCartItem(String restaurantId, int index, Map<String, dynamic> item) {
    final itemTotal = (item['price'] ?? 0) * (item['quantity'] ?? 1);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorExt.shadow.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Item',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorExt.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item['price']?.toStringAsFixed(2) ?? '0.00'} each",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 13,
                    color: colorExt.primaryText,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              color: colorExt.textfield,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _decreaseQuantity(restaurantId, index),
                  icon: Icon(
                    item['quantity'] > 1 ? Icons.remove : Icons.delete,
                    color: item['quantity'] > 1 ? colorExt.primary : Colors.red,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                ),
                Text(
                  "${item['quantity']}",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorExt.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => _increaseQuantity(restaurantId, index),
                  icon: Icon(Icons.add, color: colorExt.primary, size: 20),
                  constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                ),
              ],
            ),
          ),

          // Item Total
          SizedBox(
            width: 70,
            child: Text(
              "\$${itemTotal.toStringAsFixed(2)}",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorExt.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorExt.container,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: colorExt.shadow,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total (${cartService.totalItems} items)",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    color: colorExt.primaryText,
                  ),
                ),
                Text(
                  "\$${cartService.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorExt.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _placingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorExt.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _placingOrder
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Place Order",
                        style: TextStyle(
                          fontFamily: 'Metropolis',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
