import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/services/cart_service.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';
import 'package:speakdine_app/services/payment_service.dart';
import 'payment_methods_view.dart';
import 'order_success_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final CartService _cartService = CartService();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  String _selectedAddress = "Primary Home";
  final List<String> _addresses = ["Primary Home", "Office (DHA)", "Guest House"];
  String _paymentMethod = "cod"; // "cod" or "online"
  SavedCard? _selectedCard;
  String? _stripeCustomerId;

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      if (_cartService.currentRestaurantId == null) throw Exception("No restaurant found for cart items");

      final orderSteps = _cartService.items.map((e) => e.menuItem).toList();
      double amount = _cartService.totalAmount + 150;

      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      if (_paymentMethod == "online") {
        _stripeCustomerId ??= await PaymentService.ensureStripeCustomer(
          userId: user.uid,
          email: user.email ?? "",
          name: user.displayName ?? "Customer",
        );

        if (_selectedCard != null) {
          bool success = await PaymentService.chargeWithSavedCard(
            stripeCustomerId: _stripeCustomerId!,
            paymentMethodId: _selectedCard!.id,
            amount: amount,
            orderId: orderId,
          );
          if (!success) throw Exception("Payment failed. Please try another method.");
        } else {
          String? sessionId = await PaymentService.openCheckout(
            stripeCustomerId: _stripeCustomerId,
            items: _cartService.items.map((e) => {
              'name': e.menuItem.name,
              'price': e.menuItem.price,
              'quantity': e.quantity,
            }).toList(),
            orderId: orderId,
          );
          if (sessionId == null) throw Exception("Could not initialize checkout session.");
          
          PremiumSnackbar.show(context, message: "Please complete payment in the opened window.");
          setState(() => _isLoading = false);
          return; 
        }
      }

      final order = OrderModel(
        userId: user.uid,
        userName: user.displayName ?? "Customer",
        items: orderSteps,
        totalAmount: amount,
        createdAt: DateTime.now(),
      );
      
      final realOrderId = await _dbService.placeOrder(order, _cartService.currentRestaurantId!);
      _cartService.clearCart();
      
      if(!mounted) return;
      Navigator.pushAndRemoveUntil(
         context, 
         PremiumPageTransition(page: OrderSuccessView(orderId: realOrderId)),
         (route) => route.isFirst
      );

    } catch(e) {
      if (mounted) PremiumSnackbar.show(context, message: e.toString(), isError: true);
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Checkout", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Metropolis', color: theme.colorScheme.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildSectionTitle("Delivery Address", theme),
             const SizedBox(height: 16),
             ..._addresses.map((addr) => _buildAddressTile(addr, theme)).toList().animate(interval: 100.ms).fadeIn().slideX(begin: -0.1),
             
             const SizedBox(height: 32),
             _buildSectionTitle("Payment Method", theme),
             const SizedBox(height: 16),
             _buildPaymentTile("cod", "Cash on Delivery", "Pay when you receive", Icons.payments_rounded, Colors.green, theme),
             const SizedBox(height: 12),
             _buildPaymentTile("online", "Pay Online", "Stripe Secure Payment", Icons.credit_card_rounded, Colors.blue, theme),
             
             if (_paymentMethod == "online") ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, PremiumPageTransition(page: const PaymentMethodsView()));
                    }, 
                    icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                    label: const Text("Manage Payment Methods", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                )
             ],
             
             const SizedBox(height: 40),
             _buildSectionTitle("Order Summary", theme),
             const SizedBox(height: 16),
             _buildSummaryCard(theme).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
             
             const SizedBox(height: 48),
             _buildPlaceOrderButton(theme).animate().slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, fontFamily: 'Metropolis'),
    );
  }

  Widget _buildAddressTile(String addr, ThemeData theme) {
    bool isSelected = _selectedAddress == addr;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = addr),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant, width: 2),
        ),
        child: Row(
          children: [
            Icon(addr.contains("Home") ? Icons.home_rounded : addr.contains("Office") ? Icons.work_rounded : Icons.location_on_rounded, 
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Text(addr, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String val, String title, String sub, IconData icon, Color color, ThemeData theme) {
    bool isSelected = _paymentMethod == val;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = val),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface)),
                Text(sub, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Sub Total", _cartService.totalAmount, theme),
          const SizedBox(height: 12),
          _buildSummaryRow("Delivery Fee", 150, theme),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          _buildSummaryRow("Total Amount", _cartService.totalAmount + 150, theme, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, ThemeData theme, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: isTotal ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
          fontSize: isTotal ? 18 : 15,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
        )),
        Text("Rs. ${amount.toStringAsFixed(0)}", style: TextStyle(
          color: isTotal ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontSize: isTotal ? 22 : 16,
          fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
        )),
      ],
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        child: _isLoading 
          ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : const Text("PLACE MY ORDER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
      ),
    );
  }
}

