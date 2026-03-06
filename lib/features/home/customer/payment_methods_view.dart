import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';
import 'package:speakdine_app/services/payment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_card_view.dart';

class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  List<SavedCard> _realCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final customerId = await PaymentService.ensureStripeCustomer(
        userId: user.uid,
        email: user.email ?? "",
        name: user.displayName ?? "Customer",
      );
      if (customerId != null) {
        final cards = await PaymentService.getSavedCards(stripeCustomerId: customerId);
        setState(() {
          _realCards = cards;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  final List<Map<String, dynamic>> _otherMethods = [
    {
      "name": "Cash on Delivery",
      "icon": Icons.money_rounded,
      "color": Colors.green,
    },
    {
      "name": "Digital Wallet",
      "icon": Icons.account_balance_wallet_rounded,
      "color": Colors.orange,
    }
  ];

  String _selectedMethod = "Cash on Delivery";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        title: Text(
          "Payment",
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
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Saved Cards"),
            const SizedBox(height: 16),
            _buildCardsList(),
            const SizedBox(height: 32),
            _buildSectionHeader("Other Methods"),
            const SizedBox(height: 16),
            _buildOtherMethodsList(theme),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCTA(theme),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: TextStyle(
          color: colorExt.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: 'Metropolis'
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _realCards.length + 1,
        itemBuilder: (context, index) {
          if (index == _realCards.length) {
            return _buildAddCardButton();
          }
          var card = _realCards[index];
          return _buildCardItem(card);
        },
      ),
    );
  }

  Widget _buildCardItem(SavedCard card) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
              Text(
                card.brand.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "**** **** **** ${card.last4}",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("EXPIRY", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text("${card.expMonth}/${card.expYear}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms).fadeIn();
  }

  Widget _buildAddCardButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, PremiumPageTransition(page: const AddCardView()));
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorExt.primary.withValues(alpha: 0.1), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: colorExt.primary, size: 40),
            const SizedBox(height: 8),
            Text("Add Card", style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMethodsList(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _otherMethods.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        var method = _otherMethods[index];
        bool isSelected = _selectedMethod == method["name"];
        
        return InkWell(
          onTap: () => setState(() => _selectedMethod = method["name"]),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? colorExt.primary : Colors.transparent, width: 2),
              boxShadow: isSelected ? [] : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (method["color"] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(method["icon"], color: method["color"], size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  method["name"],
                  style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const Spacer(),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? colorExt.primary : colorExt.placeholder,
                ),
              ],
            ),
          ),
        ).animate(delay: (index * 100).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildBottomCTA(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
        ]
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorExt.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0
            ),
            child: const Text("USE THIS METHOD", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
          ),
        ),
      ),
    );
  }
}
