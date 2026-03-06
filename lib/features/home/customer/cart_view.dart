import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/services/cart_service.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/custom_popups.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'checkout_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_updateCart);
  }

  @override
  void dispose() {
    _cartService.removeListener(_updateCart);
    super.dispose();
  }

  void _updateCart() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var items = _cartService.items;

    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'Metropolis'
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                CustomPopups.showPremiumAlert(
                  context,
                  title: "Clear Cart?",
                  message: "Remove all items from your cart?",
                  onConfirm: () {
                    _cartService.clearCart();
                    PremiumSnackbar.show(context, message: "Cart cleared");
                  },
                );
              },
              child: Text("Clear", style: TextStyle(color: colorExt.error, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     padding: const EdgeInsets.all(30),
                     decoration: BoxDecoration(color: colorExt.primaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
                     child: Icon(Icons.shopping_bag_outlined, size: 80, color: colorExt.primary),
                   ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
                   const SizedBox(height: 24),
                   Text(
                    "Your cart is empty",
                    style: TextStyle(
                      color: colorExt.primaryText, 
                      fontSize: 20, 
                      fontWeight: FontWeight.w900
                    ),
                   ).animate().fade(),
                   const SizedBox(height: 8),
                   Text(
                    "Looks like you haven't added\nany food yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorExt.secondaryText, 
                      fontSize: 16, 
                    ),
                   ).animate().fade(delay: 200.ms),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      var cartItem = items[index];
                      return Dismissible(
                        key: Key(cartItem.menuItem.id ?? UniqueKey().toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: colorExt.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24)
                          ),
                          child: Icon(Icons.delete_outline_rounded, color: colorExt.error, size: 30),
                        ),
                        onDismissed: (_) {
                          _cartService.removeFromCart(cartItem);
                          PremiumSnackbar.show(context, message: "Item removed");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  color: colorExt.secondaryContainer,
                                  child: cartItem.menuItem.imageUrl != null 
                                    ? Image.network(cartItem.menuItem.imageUrl!, fit: BoxFit.cover)
                                    : Icon(Icons.fastfood_rounded, color: colorExt.secondaryText, size: 30),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.menuItem.name,
                                      style: TextStyle(
                                        color: colorExt.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rs. ${cartItem.menuItem.price.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        color: colorExt.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorExt.textField,
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: (){ _cartService.removeFromCart(cartItem); }, 
                                      icon: const Icon(Icons.remove, size: 18),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text("${cartItem.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      onPressed: (){ _cartService.addToCart(cartItem.menuItem, _cartService.currentRestaurantId!); }, 
                                      icon: const Icon(Icons.add, size: 18, color: Colors.green),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ).animate().slideX(begin: 0.1, delay: (index * 100).ms);
                    },
                  ),
                ),
                _buildReceiptSummary(),
              ],
            ),
    );
  }

  Widget _buildReceiptSummary() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: TextStyle(color: colorExt.secondaryText, fontSize: 16)),
              Text("Rs. ${_cartService.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery", style: TextStyle(color: colorExt.secondaryText, fontSize: 16)),
              const Text("Free", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: colorExt.secondaryText.withValues(alpha: 0.2)), // Placeholder for dashed line if needed
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: TextStyle(color: colorExt.primaryText, fontSize: 20, fontWeight: FontWeight.w900)),
              Text("Rs. ${_cartService.totalAmount.toStringAsFixed(0)}", style: TextStyle(color: colorExt.primary, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutView()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorExt.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                "Place Order",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ).animate().scale(delay: 200.ms),
        ],
      ),
    );
  }
}
