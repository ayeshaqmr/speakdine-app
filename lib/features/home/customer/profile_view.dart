import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';
import 'package:speakdine_app/features/auth/views/login_screen.dart';
import 'order_history_view.dart';
import 'notifications_view.dart';
import 'payment_methods_view.dart';
import 'settings_view.dart';
import 'help_view.dart';
import 'addresses_view.dart';
import 'favorites_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PremiumPageTransition(page: const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildHeader(user).animate().fadeIn().slideY(begin: -0.2),
            const SizedBox(height: 40),
            _buildMenuSection(theme).animate().fadeIn().slideY(begin: 0.1, delay: 200.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User? user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background rings
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorExt.primary.withValues(alpha: 0.1), width: 1),
              ),
            ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 2.seconds),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorExt.primary.withValues(alpha: 0.2), width: 1),
              ),
            ),
            // Avatar
            Hero(
              tag: "profile_avatar",
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: colorExt.primaryContainer,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null 
                    ? Icon(Icons.person_rounded, size: 60, color: colorExt.primary)
                    : null,
                ),
              ),
            ),
            // Edit Button
            Positioned(
              right: 10,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorExt.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3)
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Text(
          user?.displayName ?? "Guest User",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorExt.primaryText, fontFamily: 'Metropolis'),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? "no-email@test.com",
          style: TextStyle(fontSize: 14, color: colorExt.secondaryText, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMenuSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuGroup(
            theme,
            "Account",
            [
              _buildMenuItem("Order History", Icons.history_rounded, theme, () {
                Navigator.push(context, PremiumPageTransition(page: const OrderHistoryView()));
              }),
              _buildMenuItem("My Addresses", Icons.location_on_rounded, theme, () {
                Navigator.push(context, PremiumPageTransition(page: const AddressesView()));
              }),
              _buildMenuItem("My Favorites", Icons.favorite_rounded, theme, () {
                Navigator.push(context, PremiumPageTransition(page: const FavoritesView()));
              }),
              _buildMenuItem("Payments & Cards", Icons.credit_card_rounded, theme, () {
                Navigator.push(context, PremiumPageTransition(page: const PaymentMethodsView()));
              }),
            ]
          ),
          const SizedBox(height: 24),
          _buildMenuGroup(
            theme,
            "General",
            [
              _buildMenuItem("Notifications", Icons.notifications_rounded, theme, () {
                 Navigator.push(context, PremiumPageTransition(page: const NotificationsView()));
              }),
              _buildMenuItem("Settings", Icons.settings_rounded, theme, () {
                Navigator.push(context, PremiumPageTransition(page: const CustomerSettingsView()));
              }),
              _buildMenuItem("Help & Support", Icons.help_center_rounded, theme, () {
                Navigator.push(context, PremiumPageTransition(page: const CustomerHelpView()));
              }),
            ]
          ),
          const SizedBox(height: 24),
          _buildMenuItem("Sign Out", Icons.logout_rounded, theme, _signOut, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, ThemeData theme, VoidCallback onTap, {bool isDestructive = false}) {
    Color itemColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    Color iconColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    // Separate decoration for standalone Sign Out button vs group items?
    // For simplicity, reusing list tile style. If destructive, maybe wrap in container.
    
    if (isDestructive) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: iconColor, size: 24),
          title: Text(title, style: TextStyle(color: itemColor, fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20)
      ),
      title: Text(
        title, 
        style: TextStyle(color: itemColor, fontWeight: FontWeight.w700, fontSize: 15),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.5), size: 20),
    );
  }
}
