import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speakdine_app/features/auth/views/login_screen.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakdine_app/services/payment_service.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'package:speakdine_app/widgets/location_picker.dart';
import 'settings_view.dart';
import 'support_view.dart';

class RestaurantProfileView extends StatefulWidget {
  const RestaurantProfileView({super.key});

  @override
  State<RestaurantProfileView> createState() => _RestaurantProfileViewState();
}

class _RestaurantProfileViewState extends State<RestaurantProfileView> {
  final TextEditingController _nameController = TextEditingController(text: "Tasty Bites Restaurant");
  final TextEditingController _emailController = TextEditingController(text: "contact@tastybites.com");
  final TextEditingController _phoneController = TextEditingController(text: "+92 300 1234567");
  final TextEditingController _addressController = TextEditingController(text: "Main Boulevard, Gulberg III, Lahore");
  bool _isSettingUpPayment = false;
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: LocationPicker(
            onLocationSelected: (lat, lng, address) {
              setState(() {
                _addressController.text = address;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) PremiumSnackbar.show(context, message: "Error picking image", isError: true);
    }
  }

  Future<void> _setupStripe() async {
    setState(() => _isSettingUpPayment = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final result = await PaymentService.createConnectAccount(restaurantId: user.uid, email: user.email ?? "");
      if (result != null) {
        final link = await PaymentService.getOnboardingLink(accountId: result['accountId']!);
        if (link != null) {
          final uri = Uri.parse(link);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      }
    } catch (e) {
      if (mounted) PremiumSnackbar.show(context, message: "Could not setup payments", isError: true);
    } finally {
      if (mounted) setState(() => _isSettingUpPayment = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PremiumPageTransition(page: const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Restaurant Profile",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Accessed via Bottom Nav
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                 PremiumSnackbar.show(context, message: "Profile Updated!");
              },
              child: Text("SAVE", style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: colorExt.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      image: _logoFile != null 
                        ? DecorationImage(image: FileImage(_logoFile!), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _logoFile == null 
                      ? Center(child: Icon(Icons.storefront_rounded, size: 64, color: colorExt.primary))
                      : null,
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: IconButton.filled(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.camera_alt_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: colorExt.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Section Card
            Card(
               elevation: 0,
               color: colorExt.surfaceContainerLow,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text("BUSINESS INFORMATION", style: TextStyle(color: colorExt.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      _buildTextField("Restaurant Name", _nameController, Icons.restaurant_rounded),
                      const SizedBox(height: 16),
                      _buildTextField("Email Address", _emailController, Icons.email_rounded),
                      const SizedBox(height: 16),
                      _buildTextField("Phone Number", _phoneController, Icons.phone_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Physical Address", 
                        _addressController, 
                        Icons.location_on_rounded, 
                        maxLines: 3,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.map_rounded, color: colorExt.primary),
                          onPressed: _showLocationPicker,
                        ),
                      ),
                   ],
                 ),
               ),
            ),

            const SizedBox(height: 24),

            // Payments Section
            Card(
               elevation: 0,
               color: colorExt.surfaceContainerLow,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text("PAYMENT INTEGRATION", style: TextStyle(color: colorExt.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance_rounded, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Stripe Connect", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: colorExt.primaryText)),
                                Text("Receive payments directly", style: TextStyle(fontSize: 12, color: colorExt.secondaryText, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          _isSettingUpPayment 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : FilledButton.tonal(
                                onPressed: _setupStripe, 
                                child: const Text("SETUP", style: TextStyle(fontWeight: FontWeight.bold))
                              )
                        ],
                      ),
                   ],
                 ),
               ),
            ),
 
            const SizedBox(height: 24),

            // Additional Options
            Card(
               elevation: 0,
               color: colorExt.surfaceContainerLow,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               child: Column(
                 children: [
                   _buildMenuTile("Store Settings", Icons.settings_rounded, () {
                      Navigator.push(context, PremiumPageTransition(page: const RestaurantSettingsView()));
                   }),
                   const Divider(indent: 56, endIndent: 16, height: 1),
                   _buildMenuTile("Help & Support", Icons.help_center_rounded, () {
                      Navigator.push(context, PremiumPageTransition(page: const RestaurantSupportView()));
                   }),
                   const Divider(indent: 56, endIndent: 16, height: 1),
                   _buildMenuTile("Sign Out", Icons.logout_rounded, _signOut, isDestructive: true),
                 ],
               ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {},
                child: const Text("UPDATE BUSINESS INFO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorExt.primary, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.red : colorExt.primary),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w700, 
          color: isDestructive ? Colors.red : colorExt.primaryText
        )
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}
