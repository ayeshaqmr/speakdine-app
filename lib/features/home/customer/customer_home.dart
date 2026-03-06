import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/home/customer/customer_transactions_view.dart';
import 'package:speakdine_app/features/home/customer/order_history_view.dart';
import 'package:speakdine_app/features/home/customer/cart_view.dart';
import 'package:speakdine_app/features/home/customer/home_view.dart';
import 'package:speakdine_app/features/home/customer/profile_view.dart';
import 'package:speakdine_app/widgets/app_dock.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RadixIcons;
import 'package:speakdine_app/widgets/voice_assistant_bubble.dart';
import 'package:speakdine_app/features/home/customer/search_selection_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakdine_app/features/auth/views/login_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerMainViewState();
}

class _CustomerMainViewState extends State<CustomerHome> {
  int selectTab = 0;
  final PageStorageBucket storageBucket = PageStorageBucket();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Widget> _pages = [
    const HomeView(),
    const CartView(),
    const OrderHistoryView(),
    const CustomerTransactionsView(),
    const ProfileView(),
  ];

  void _onTabTapped(int index) {
    setState(() => selectTab = index);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        bucket: storageBucket, 
        child: IndexedStack(
          index: selectTab,
          children: _pages,
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AppDock(
        items: [
          DockItem(icon: RadixIcons.home, label: 'Home'),
          DockItem(icon: RadixIcons.reader, label: 'Cart'),
          DockItem(icon: RadixIcons.archive, label: 'Orders'),
          DockItem(icon: RadixIcons.cardStack, label: 'Payments'),
          DockItem(icon: RadixIcons.person, label: 'Profile'),
        ],
        selectedIndex: selectTab,
        onTap: _onTabTapped,
      ),
      floatingActionButton: VoiceAssistantBubble(
        onCommand: (intent, query) {
          if (intent == "NAV_HOME") _onTabTapped(0);
          else if (intent == "NAV_CART") _onTabTapped(1);
          else if (intent == "NAV_ORDERS") _onTabTapped(2);
          else if (intent == "NAV_PROFILE") _onTabTapped(4);
          else if (intent == "LOGOUT") _signOut();
          else if (intent == "SEARCH" && query != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchSelectionView(initialQuery: query)));
          }
        },
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
        if (index == 0) _onTabTapped(0); // Home
        else if (index == 1) _onTabTapped(1); // Cart
        else if (index == 2) _onTabTapped(2); // Orders
        else if (index == 3) _onTabTapped(4); // Profile
        else if (index == 5) _signOut(); // Logout (index 4 is the Divider, so logout is 5)
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
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 4),
              Text(
                'Dine with Independence',
                style: TextStyle(
                  color: colorExt.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
            icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart_rounded),
          label: Text('My Cart'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.history_rounded),
          selectedIcon: Icon(Icons.history_rounded),
          label: Text('Orders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('My Profile'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.logout_rounded, color: Colors.indigo),
          label: Text('Logout', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
