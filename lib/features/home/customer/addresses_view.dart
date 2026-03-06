import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/location_picker.dart';
import 'package:speakdine_app/utils/toast_helper.dart';

class AddressesView extends StatefulWidget {
  const AddressesView({super.key});

  @override
  State<AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
  final List<Map<String, String>> _addresses = [
    {"label": "Home", "address": "Main Boulevard, Gulberg III, Lahore"},
    {"label": "Office", "address": "DHA Phase 5, Lahore"},
  ];

  void _addAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Add New Address",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorExt.primaryText, fontFamily: 'Metropolis'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LocationPicker(
                  onLocationSelected: (lat, lng, address) {
                    setState(() {
                      _addresses.add({"label": "New Address", "address": address});
                    });
                    Navigator.pop(context);
                    showAppToast(context, "Address added successfully!");
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("My Addresses", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Metropolis', color: colorExt.primaryText)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty 
              ? _buildEmptyState() 
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return _buildAddressCard(addr, index);
                  },
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _addAddress,
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text("ADD NEW ADDRESS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 80, color: colorExt.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text("No addresses saved", style: TextStyle(fontSize: 16, color: colorExt.secondaryText, fontWeight: FontWeight.bold)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildAddressCard(Map<String, String> addr, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorExt.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              addr['label'] == 'Home' ? Icons.home_rounded : 
              addr['label'] == 'Office' ? Icons.work_rounded : Icons.location_on_rounded,
              color: colorExt.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addr['label']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorExt.primaryText)),
                const SizedBox(height: 4),
                Text(addr['address']!, style: TextStyle(fontSize: 13, color: colorExt.secondaryText, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: colorExt.placeholder),
            onPressed: () {},
          ),
        ],
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
  }
}
