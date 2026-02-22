import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:speak_dine/widgets/app_dock.dart';
import 'package:speak_dine/view/restaurant/menu_management.dart';
import 'package:speak_dine/view/restaurant/orders_view.dart';
import 'package:speak_dine/view/restaurant/qr_code_view.dart';
import 'package:speak_dine/view/restaurant/restaurant_profile.dart';
import 'package:speak_dine/view/restaurant/restaurant_transactions_view.dart';

const _restaurantDockItems = [
  DockItem(icon: RadixIcons.reader, label: 'Menu'),
  DockItem(icon: RadixIcons.archive, label: 'Orders'),
  DockItem(icon: RadixIcons.cardStack, label: 'Payments'),
  DockItem(icon: RadixIcons.viewGrid, label: 'QR Code'),
  DockItem(icon: RadixIcons.person, label: 'Profile'),
];

class RestaurantShell extends StatefulWidget {
  const RestaurantShell({super.key});

  @override
  State<RestaurantShell> createState() => _RestaurantShellState();
}

class _RestaurantShellState extends State<RestaurantShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      child: Container(
        color: theme.colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: const [
                    MenuManagementView(),
                    OrdersView(),
                    RestaurantTransactionsView(),
                    QRCodeView(),
                    RestaurantProfileView(),
                  ],
                ),
              ),
              AppDock(
                items: _restaurantDockItems,
                selectedIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
