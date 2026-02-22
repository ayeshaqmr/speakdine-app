import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/services/cart_service.dart';
import 'package:speak_dine/services/payment_service.dart';

class CartView extends StatefulWidget {
  final bool embedded;

  const CartView({super.key, this.embedded = false});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _placingOrder = false;

  void _increaseQuantity(String restaurantId, int index) {
    setState(() => cartService.increaseQuantity(restaurantId, index));
  }

  void _decreaseQuantity(String restaurantId, int index) {
    setState(() => cartService.decreaseQuantity(restaurantId, index));
  }

  void _showPaymentMethodDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Method'),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you like to pay?').muted().small(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _placeOrder(paymentMethod: 'online');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RadixIcons.globe, size: 16),
                      SizedBox(width: 8),
                      Text('Pay Online'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlineButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _placeOrder(paymentMethod: 'cod');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RadixIcons.archive, size: 16,
                          color: theme.colorScheme.foreground),
                      const SizedBox(width: 8),
                      const Text('Cash on Delivery'),
                    ],
                  ),
                ),
              ),
              FutureBuilder<_SavedCardOption?>(
                future: _loadSavedCardOption(),
                builder: (context, snap) {
                  if (!snap.hasData || snap.data == null) {
                    return const SizedBox.shrink();
                  }
                  final option = snap.data!;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlineButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _placeOrder(
                            paymentMethod: 'saved_card',
                            stripeCustomerId: option.stripeCustomerId,
                            savedCardId: option.card.id,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(RadixIcons.cardStack, size: 16,
                                color: theme.colorScheme.foreground),
                            const SizedBox(width: 8),
                            Text('${option.card.brand.toUpperCase()} ···· ${option.card.last4}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<_SavedCardOption?> _loadSavedCardOption() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final customerId = doc.data()?['stripeCustomerId'] as String?;
    if (customerId == null || customerId.isEmpty) return null;
    final cards = await PaymentService.getSavedCards(stripeCustomerId: customerId);
    if (cards.isEmpty) return null;
    return _SavedCardOption(stripeCustomerId: customerId, card: cards.first);
  }

  Future<void> _placeOrder({
    required String paymentMethod,
    String? stripeCustomerId,
    String? savedCardId,
  }) async {
    if (cartService.isEmpty) return;

    setState(() => _placingOrder = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final customerName = userData['name'] ?? 'Customer';
      final customerPhone = userData['phone'] ?? '';
      final customerEmail = userData['email'] ?? user.email ?? '';
      final customerLat = (userData['lat'] as num?)?.toDouble();
      final customerLng = (userData['lng'] as num?)?.toDouble();
      final customerAddress = userData['address'] as String? ?? '';

      if (customerLat == null || customerLng == null) {
        if (!mounted) return;
        setState(() => _placingOrder = false);
        showAppToast(context, 'Please set your delivery location in your profile first.');
        return;
      }

      final initialStatus = paymentMethod == 'online' ? 'awaiting_payment' : 'pending';
      final paymentStatus = paymentMethod == 'cod' ? 'pending' : 'pending';

      for (var entry in cartService.cart.entries) {
        final restaurantId = entry.key;
        final items = entry.value;

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

        final customerOrderRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc();

        final restaurantOrderRef = await _firestore
            .collection('restaurants')
            .doc(restaurantId)
            .collection('orders')
            .add({
          'customerId': user.uid,
          'customerOrderId': customerOrderRef.id,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerEmail': customerEmail,
          'customerLat': customerLat,
          'customerLng': customerLng,
          'customerAddress': customerAddress,
          'items': orderItems,
          'itemCount': totalQuantity,
          'total': restaurantTotal,
          'status': initialStatus,
          'paymentMethod': paymentMethod == 'saved_card' ? 'online' : paymentMethod,
          'paymentStatus': paymentStatus,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await customerOrderRef.set({
          'restaurantId': restaurantId,
          'restaurantOrderId': restaurantOrderRef.id,
          'restaurantName': items.first['restaurantName'] ?? 'Restaurant',
          'items': orderItems,
          'itemCount': totalQuantity,
          'total': restaurantTotal,
          'status': initialStatus,
          'paymentMethod': paymentMethod == 'saved_card' ? 'online' : paymentMethod,
          'paymentStatus': paymentStatus,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (paymentMethod == 'online') {
          final customerId = stripeCustomerId ??
              await PaymentService.ensureStripeCustomer(
                userId: user.uid,
                email: customerEmail,
                name: customerName,
              );

          await PaymentService.openCheckout(
            stripeCustomerId: customerId,
            items: orderItems,
            orderId: customerOrderRef.id,
          );
        }

        if (paymentMethod == 'saved_card' && savedCardId != null) {
          final charged = await PaymentService.chargeWithSavedCard(
            stripeCustomerId: stripeCustomerId!,
            paymentMethodId: savedCardId,
            amount: restaurantTotal,
            orderId: customerOrderRef.id,
          );

          if (charged) {
            await restaurantOrderRef.update({
              'paymentStatus': 'paid',
              'status': 'pending',
            });
            await customerOrderRef.update({
              'paymentStatus': 'paid',
              'status': 'pending',
            });
          } else {
            if (mounted) {
              showAppToast(context, 'Card payment failed. Please try another method.');
            }
            setState(() => _placingOrder = false);
            return;
          }
        }
      }

      setState(() => cartService.clearCart());

      if (!mounted) return;

      if (paymentMethod == 'online') {
        showAppToast(context, 'Complete payment in the opened page');
      } else if (paymentMethod == 'saved_card') {
        showAppToast(context, 'Payment successful! Order placed.');
      } else {
        showAppToast(context, 'Order placed successfully!');
      }
      if (!widget.embedded) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      showAppToast(
          context, 'Something went wrong. Please try again later.');
    }

    if (mounted) setState(() => _placingOrder = false);
  }

  void _clearCart() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Remove all items from your cart?'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Cancel')],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => cartService.clearCart());
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.destructive,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Clear',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              if (!widget.embedded)
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(RadixIcons.arrowLeft, size: 20),
                ),
              if (!widget.embedded) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cart').h4().semiBold(),
                    const Text('Review your items before ordering')
                        .muted()
                        .small(),
                  ],
                ),
              ),
              if (cartService.isNotEmpty)
                GhostButton(
                  density: ButtonDensity.compact,
                  onPressed: _clearCart,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: theme.colorScheme.destructive,
                    ),
                  ).small(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: cartService.isEmpty
              ? _buildEmptyCart(theme)
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: cartService.cart.entries.map((entry) {
                    final restaurantId = entry.key;
                    final items = entry.value;
                    final restaurantName = items.isNotEmpty
                        ? items.first['restaurantName'] ?? 'Restaurant'
                        : 'Restaurant';
                    return _buildRestaurantSection(
                        theme, restaurantId, restaurantName, items);
                  }).toList(),
                ),
        ),
        if (cartService.isNotEmpty) _buildOrderSummary(theme),
      ],
    );

    if (widget.embedded) return content;

    return Scaffold(
      child: Container(
        color: theme.colorScheme.background,
        child: SafeArea(child: content),
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: theme.colorScheme.mutedForeground),
          const SizedBox(height: 16),
          const Text('Your cart is empty').semiBold(),
          const SizedBox(height: 8),
          const Text('Add some delicious food!').muted().small(),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(
    ThemeData theme,
    String restaurantId,
    String restaurantName,
    List<Map<String, dynamic>> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(RadixIcons.home,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(restaurantName).semiBold(),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildCartItem(theme, restaurantId, index, item);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    ThemeData theme,
    String restaurantId,
    int index,
    Map<String, dynamic> item,
  ) {
    final itemTotal = (item['price'] ?? 0) * (item['quantity'] ?? 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? 'Item').semiBold().small(),
                Text('${item['price']?.toStringAsFixed(2) ?? '0.00'} PKR each')
                    .muted()
                    .small(),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GhostButton(
                density: ButtonDensity.icon,
                onPressed: () => _decreaseQuantity(restaurantId, index),
                child: Icon(
                  item['quantity'] > 1
                      ? RadixIcons.minus
                      : RadixIcons.trash,
                  size: 14,
                  color: item['quantity'] > 1
                      ? theme.colorScheme.foreground
                      : theme.colorScheme.destructive,
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${item['quantity']}',
                  textAlign: TextAlign.center,
                ).semiBold().small(),
              ),
              GhostButton(
                density: ButtonDensity.icon,
                onPressed: () => _increaseQuantity(restaurantId, index),
                child: const Icon(RadixIcons.plus, size: 14),
              ),
            ],
          ),
          SizedBox(
            width: 64,
            child: Text(
              '${itemTotal.toStringAsFixed(2)} PKR',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          top: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total (${cartService.totalItems} items)').muted(),
              Text(
                '${cartService.totalAmount.toStringAsFixed(2)} PKR',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _placingOrder
                ? Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : PrimaryButton(
                    onPressed: _showPaymentMethodDialog,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Place Order')],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SavedCardOption {
  final String stripeCustomerId;
  final SavedCard card;
  const _SavedCardOption({required this.stripeCustomerId, required this.card});
}
