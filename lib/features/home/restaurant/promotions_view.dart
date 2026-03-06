import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class PromotionsView extends StatefulWidget {
  const PromotionsView({super.key});

  @override
  State<PromotionsView> createState() => _PromotionsViewState();
}

class _PromotionsViewState extends State<PromotionsView> {
  final List<Map<String, dynamic>> _promos = [
    {"code": "WELCOME20", "discount": "20% OFF", "status": "Active", "uses": 145},
    {"code": "FREEFRIES", "discount": "Free Item", "status": "Expired", "uses": 34},
  ];

  void _addPromo() {
    setState(() {
      _promos.insert(0, {"code": "NEWPROMO", "discount": "10% OFF", "status": "Active", "uses": 0});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Offers & Promos",
          style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 22, fontFamily: 'Metropolis'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPromo,
        backgroundColor: colorExt.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("New Promo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _promos.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _promos.length,
              itemBuilder: (context, index) {
                final promo = _promos[index];
                return _buildPromoCard(promo, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.discount_rounded, size: 80, color: colorExt.placeholder.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text("No active promotions", style: TextStyle(fontSize: 18, color: colorExt.secondaryText, fontWeight: FontWeight.bold)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo, int index) {
    bool isActive = promo["status"] == "Active";
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? colorExt.primary.withValues(alpha: 0.3) : colorExt.placeholder.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_offer_rounded, color: isActive ? colorExt.primary : colorExt.placeholder, size: 20),
                  const SizedBox(width: 8),
                  Text(promo["code"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: colorExt.primaryText)),
                ],
              ),
              const SizedBox(height: 12),
              Text(promo["discount"], style: TextStyle(fontSize: 16, color: isActive ? Colors.green : colorExt.secondaryText, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text("Used ${promo["uses"]} times", style: TextStyle(fontSize: 13, color: colorExt.secondaryText, fontWeight: FontWeight.w500)),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? colorExt.primary.withValues(alpha: 0.1) : colorExt.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                promo["status"],
                style: TextStyle(color: isActive ? colorExt.primary : colorExt.placeholder, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    ).animate(delay: (index * 100).ms).slideX(begin: 0.1).fadeIn();
  }
}
