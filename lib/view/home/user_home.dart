import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:speak_dine/view/authScreens/login_view.dart';
import 'package:speak_dine/view/user/restaurant_detail.dart';

class UserHomeView extends StatefulWidget {
  final VoidCallback? onCartChanged;
  final VoidCallback? onViewCart;

  const UserHomeView({super.key, this.onCartChanged, this.onViewCart});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = 'Customer';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Customer';
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $userName').h4().semiBold(),
                    const Text('What would you like to eat?')
                        .muted()
                        .small(),
                  ],
                ),
              ),
              GhostButton(
                density: ButtonDensity.icon,
                onPressed: _logout,
                child: Icon(RadixIcons.exit,
                    size: 20, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text('Restaurants Near You').semiBold(),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('restaurants').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildRestaurantListSkeleton(theme);
              }
              if (snapshot.hasError) {
                debugPrint('[UserHome] Restaurants stream error: ${snapshot.error}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    showAppToast(context, 'Unable to load restaurants. Please refresh and try again.');
                  }
                });
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.crossCircled,
                          size: 48,
                          color: theme.colorScheme.destructive),
                      const SizedBox(height: 16),
                      const Text('Unable to load restaurants').semiBold(),
                      const SizedBox(height: 8),
                      const Text('Please refresh and try again')
                          .muted()
                          .small(),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RadixIcons.home,
                          size: 48,
                          color: theme.colorScheme.mutedForeground),
                      const SizedBox(height: 16),
                      const Text('No restaurants available').muted(),
                    ],
                  ),
                );
              }
              final restaurants = snapshot.data!.docs;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: restaurants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final restaurant =
                      restaurants[index].data() as Map<String, dynamic>;
                  final restaurantId = restaurants[index].id;
                  return _buildRestaurantCard(
                      theme, restaurant, restaurantId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantListSkeleton(ThemeData theme) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Bone.square(
                      size: 48,
                      borderRadius:
                          BorderRadius.all(Radius.circular(12))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Bone.text(words: 2),
                        const SizedBox(height: 8),
                        const Bone.text(words: 4, fontSize: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    ThemeData theme,
    Map<String, dynamic> restaurant,
    String restaurantId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailView(
              restaurantId: restaurantId,
              restaurantName: restaurant['restaurantName'] ?? 'Restaurant',
              onCartChanged: () {
                setState(() {});
                widget.onCartChanged?.call();
              },
              onViewCart: widget.onViewCart,
            ),
          ),
        ).then((_) {
          setState(() {});
          widget.onCartChanged?.call();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(RadixIcons.home,
                  color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant['restaurantName'] ?? 'Restaurant')
                      .semiBold(),
                  const SizedBox(height: 4),
                  Text(restaurant['address'] ?? 'No address')
                      .muted()
                      .small(),
                ],
              ),
            ),
            Icon(RadixIcons.chevronRight,
                size: 20, color: theme.colorScheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}
