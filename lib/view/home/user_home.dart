import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:speak_dine/widgets/notification_bell.dart';
import 'package:speak_dine/view/authScreens/login_view.dart';
import 'package:speak_dine/view/user/restaurant_detail.dart';

class UserHomeView extends StatefulWidget {
  final VoidCallback? onCartChanged;
  final VoidCallback? onViewCart;

  const UserHomeView({super.key, this.onCartChanged, this.onViewCart});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

const _filterCategories = [
  'All',
  'Appetizers', 'Bakery', 'BBQ & Grills', 'Beverages', 'Biryani & Rice',
  'Breakfast', 'Burgers', 'Chinese', 'Desi', 'Desserts', 'Fast Food',
  'Healthy', 'Italian', 'Japanese', 'Mexican', 'Pasta', 'Pizza', 'Salads',
  'Sandwiches', 'Seafood', 'Sides', 'Soups', 'Steaks', 'Sushi', 'Thai',
  'Wraps', 'Other',
];

class _UserHomeViewState extends State<UserHomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = 'Customer';
  String _selectedCategory = 'All';
  Map<String, Set<String>> _restaurantCategories = {};

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
                    Text('Hello, $userName',
                        style: TextStyle(color: theme.colorScheme.primary))
                        .h4().semiBold(),
                    const Text('What would you like to eat?')
                        .muted()
                        .small(),
                  ],
                ),
              ),
              const NotificationBell(),
              const SizedBox(width: 8),
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
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filterCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _filterCategories[index];
              final isSelected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              );
            },
          ),
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
                    showAppToast(context, 'Unable to load restaurants. Please refresh and try again.', isError: true);
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
              if (_selectedCategory == 'All') {
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
              }
              return _FilteredRestaurantList(
                restaurants: restaurants,
                selectedCategory: _selectedCategory,
                theme: theme,
                buildCard: _buildRestaurantCard,
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isRestaurantOpen(Map<String, dynamic> restaurant) {
    final openTime = restaurant['openTime'] as String?;
    final closeTime = restaurant['closeTime'] as String?;
    if (openTime == null || closeTime == null) return true;

    final now = TimeOfDay.now();
    final open = _parseTime(openTime);
    final close = _parseTime(closeTime);
    if (open == null || close == null) return true;

    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    if (closeMinutes > openMinutes) {
      return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
    }
    return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
  }

  TimeOfDay? _parseTime(String timeStr) {
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false)
        .firstMatch(timeStr);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour != 12) hour += 12;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _buildRestaurantListSkeleton(ThemeData theme) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Bone(
                  width: double.infinity,
                  height: 140,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                Card(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Bone.text(words: 2),
                      const SizedBox(height: 8),
                      const Bone.text(words: 4, fontSize: 12),
                      const SizedBox(height: 8),
                      const Bone.text(words: 3, fontSize: 11),
                    ],
                  ),
                ),
              ],
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
    final coverUrl = restaurant['coverImageUrl'] as String?;
    final name = restaurant['restaurantName'] ?? 'Restaurant';
    final address = restaurant['address'] ?? '';
    final avgRating = (restaurant['averageRating'] as num?)?.toDouble();
    final totalReviews = (restaurant['totalReviews'] as int?) ?? 0;
    final isOpen = _isRestaurantOpen(restaurant);
    final openTime = restaurant['openTime'] as String?;
    final closeTime = restaurant['closeTime'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailView(
              restaurantId: restaurantId,
              restaurantName: name,
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: coverUrl != null && coverUrl.isNotEmpty
                  ? Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _coverPlaceholder(theme),
                    )
                  : _coverPlaceholder(theme),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name).semiBold()),
                      _buildStarRating(theme, avgRating ?? 0, totalReviews),
                    ],
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(RadixIcons.pinTop,
                            size: 12,
                            color: theme.colorScheme.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).muted().small(),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Colors.green.withAlpha(25)
                              : Colors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            color: isOpen ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (openTime != null && closeTime != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '$openTime - $closeTime',
                          style: TextStyle(
                            color: theme.colorScheme.mutedForeground,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const Spacer(),
                      _MenuCategoriesRow(
                        restaurantId: restaurantId,
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(ThemeData theme, double rating, int reviewCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          Color starColor;
          if (rating >= starValue) {
            starColor = Colors.amber;
          } else if (rating >= starValue - 0.5) {
            starColor = Colors.amber.withValues(alpha: 0.5);
          } else {
            starColor = theme.colorScheme.muted;
          }
          return Icon(RadixIcons.star, size: 14, color: starColor);
        }),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              color: theme.colorScheme.mutedForeground,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _coverPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Center(
        child: Icon(RadixIcons.home,
            size: 40, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
    );
  }
}

class _FilteredRestaurantList extends StatelessWidget {
  final List<QueryDocumentSnapshot> restaurants;
  final String selectedCategory;
  final ThemeData theme;
  final Widget Function(ThemeData, Map<String, dynamic>, String) buildCard;

  const _FilteredRestaurantList({
    required this.restaurants,
    required this.selectedCategory,
    required this.theme,
    required this.buildCard,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _filterByCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final filtered = snapshot.data!;
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RadixIcons.magnifyingGlass,
                    size: 48, color: theme.colorScheme.mutedForeground),
                const SizedBox(height: 16),
                Text('No restaurants offer $selectedCategory').muted(),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final restaurant = filtered[index].data() as Map<String, dynamic>;
            final restaurantId = filtered[index].id;
            return buildCard(theme, restaurant, restaurantId);
          },
        );
      },
    );
  }

  Future<List<QueryDocumentSnapshot>> _filterByCategory() async {
    final results = <QueryDocumentSnapshot>[];
    for (final doc in restaurants) {
      final menuSnap = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(doc.id)
          .collection('menu')
          .where('category', isEqualTo: selectedCategory)
          .limit(1)
          .get();
      if (menuSnap.docs.isNotEmpty) {
        results.add(doc);
      }
    }
    return results;
  }
}

class _MenuCategoriesRow extends StatelessWidget {
  final String restaurantId;
  final ThemeData theme;

  const _MenuCategoriesRow({
    required this.restaurantId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['category'] as String?) ?? '';
            })
            .where((c) => c.isNotEmpty)
            .toSet()
            .take(3)
            .toList();

        if (categories.isEmpty) return const SizedBox.shrink();

        return Flexible(
          child: Text(
            categories.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.mutedForeground,
              fontSize: 11,
            ),
          ),
        );
      },
    );
  }
}
