import 'package:flutter/material.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/app_dock.dart';
import 'package:speakdine_app/features/home/restaurant/dashboard_view.dart';
import 'package:speakdine_app/features/home/restaurant/menu_management_view.dart';
import 'package:speakdine_app/features/home/restaurant/order_management_view.dart';
import 'package:speakdine_app/features/home/restaurant/restaurant_transactions_view.dart';
import 'package:speakdine_app/features/home/restaurant/restaurant_profile_view.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RadixIcons;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakdine_app/features/auth/views/login_screen.dart';
import 'package:speakdine_app/core/routes/route_transitions.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  int _selectedIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const RestaurantDashboardView(),
    const MenuManagementView(),
    const OrderManagementView(),
    const RestaurantTransactionsView(),
    const RestaurantProfileView(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
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
      key: _scaffoldKey,
      backgroundColor: colorExt.surface,
      drawer: _buildDrawer(),
      body: PageStorage(
        bucket: _bucket,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80), // Space for AppDock
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AppDock(
        items: [
          DockItem(icon: RadixIcons.dashboard, label: 'Dashboard'),
          DockItem(icon: RadixIcons.reader, label: 'Menu'),
          DockItem(icon: RadixIcons.archive, label: 'Orders'),
          DockItem(icon: RadixIcons.cardStack, label: 'Payments'),
          DockItem(icon: RadixIcons.person, label: 'Profile'),
        ],
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDrawer() {
    return NavigationDrawer(
      backgroundColor: colorExt.surface,
      indicatorColor: colorExt.primaryContainer,
      onDestinationSelected: (index) {
        Navigator.pop(context);
        if (index == 0) _onTabTapped(0); // Dashboard
        else if (index == 1) _onTabTapped(1); // Menu
        else if (index == 2) _onTabTapped(2); // Orders
        else if (index == 3) _onTabTapped(4); // Profile
        else if (index == 5) _signOut(); // Logout
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 40, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPEAK DINE',
                style: TextStyle(
                  color: colorExt.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontFamily: 'Metropolis'
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your restaurant',
                style: TextStyle(
                  color: colorExt.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: Text('Menu Manager'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: Text('Orders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront_rounded),
          label: Text('Business Profile'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.logout_rounded, color: Colors.red),
          label: Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

