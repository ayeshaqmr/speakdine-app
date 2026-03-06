import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/features/home/customer/search_selection_view.dart';
import 'package:speakdine_app/widgets/location_picker.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'restaurant_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController txtSearch = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  Color _parseColor(dynamic colorData) {
    if (colorData == null) return const Color(0xFFC8E6C9);
    if (colorData is int) return Color(colorData);
    if (colorData is String) {
      if (colorData.startsWith('0x')) {
        return Color(int.parse(colorData));
      }
      if (colorData.startsWith('#')) {
        return Color(int.parse(colorData.replaceFirst('#', '0xFF')));
      }
      return Color(int.parse('0xFF$colorData'));
    }
    return const Color(0xFFC8E6C9);
  }

  // Localized Pakistani Categories - Visual Anchors
  final List<Map> catArr = [
    {"icon": Icons.rice_bowl_rounded, "name": "Biryani", "color": const Color(0xFFFF9800)},
    {"icon": Icons.kebab_dining_rounded, "name": "BBQ", "color": const Color(0xFFD32F2F)},
    {"icon": Icons.soup_kitchen_rounded, "name": "Karahi", "color": const Color(0xFF388E3C)},
    {"icon": Icons.local_pizza_rounded, "name": "Fast Food", "color": const Color(0xFFFBC02D)},
    {"icon": Icons.local_cafe_rounded, "name": "Chai", "color": const Color(0xFF795548)},
    {"icon": Icons.icecream_rounded, "name": "Dessert", "color": const Color(0xFFE91E63)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocation();
    });
  }

  void _checkLocation() {
    // Simulate checking if location is set. In real app, check user doc in Firestore.
    _showLocationPrompt();
  }

  void _showLocationPrompt() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   Text(
                    "Set Delivery Location",
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: colorExt.primaryText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select your location on the map to see restaurants that deliver to you.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 14, color: colorExt.secondaryText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LocationPicker(
                  onLocationSelected: (lat, lng, address) {
                    // In a real app, save to Firestore here
                    Navigator.pop(context);
                    PremiumSnackbar.show(context, message: "Location set to: $address");
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildSalamHeader().animate().fade(duration: 600.ms).slideY(begin: -0.2, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            _buildSearchPill().animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            _buildCategories(),
            const SizedBox(height: 32),
            _buildSectionHeader("Trending in Lahore", onStatsTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchSelectionView(initialQuery: "Trending")));
            }),
            _buildTrendingListStream(),
            const SizedBox(height: 32),
            _buildSectionHeader("Desi Favorites", onStatsTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchSelectionView(initialQuery: "Desi")));
            }),
            _buildFavoriteListStream(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingListStream() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.streamTrendingRestaurants(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildTrendingPlaceholder(); // Helper for empty/loading state
        }
        final list = snapshot.data!;
        return SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) => _buildRestaurantCard(list[index], index),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteListStream() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.streamRestaurants(), // General list for now as favorites
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildFavoritePlaceholder();
        }
        final list = snapshot.data!;
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: list.length > 5 ? 5 : list.length, // Show top 5
          itemBuilder: (context, index) => _buildFavoriteRow(list[index], index),
        );
      },
    );
  }

  // Refactored UI builders from the original popArr logic
  Widget _buildRestaurantCard(Map<String, dynamic> pObj, int index) {
     return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RestaurantDetailView(restaurantObj: pObj))),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(8), bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: "restaurant_image_${pObj["name"]}",
                  child: Container(
                    decoration: BoxDecoration(
                      color: _parseColor(pObj['color']),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(8)),
                    ),
                    child: const Center(child: Icon(Icons.storefront_rounded, size: 60, color: Colors.white54)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pObj["name"] ?? "Unnamed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorExt.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(pObj["rate"]?.toString() ?? "4.5", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text("• ${pObj["food_type"] ?? "Desi"}", style: TextStyle(color: colorExt.secondaryText, fontSize: 13))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: (index * 150).ms).scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTrendingPlaceholder() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Text(
          "Loading trending restaurants...",
          style: TextStyle(color: colorExt.secondaryText),
        ),
      ),
    );
  }

  Widget _buildFavoritePlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Text(
          "Loading favorite restaurants...",
          style: TextStyle(color: colorExt.secondaryText),
        ),
      ),
    );
  }

  Widget _buildFavoriteRow(Map<String, dynamic> fObj, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RestaurantDetailView(restaurantObj: fObj)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          children: [
            Hero(
              tag: "restaurant_image_${fObj["name"]}_fav",
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _parseColor(fObj['color']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.storefront_rounded, size: 30, color: Colors.white54)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fObj["name"] ?? "Unnamed",
                    style: TextStyle(
                      color: colorExt.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${fObj["food_type"] ?? "Desi"} • ${fObj["type"] ?? "Restaurant"}",
                    style: TextStyle(
                      color: colorExt.secondaryText,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        fObj["rate"]?.toString() ?? "4.5",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${fObj["rating"] ?? "0"})",
                        style: TextStyle(
                          color: colorExt.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: colorExt.placeholder, size: 18),
          ],
        ),
      ).animate(delay: (index * 100).ms).slideX(begin: 0.2, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSalamHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.isNotEmpty) ? user.displayName! : "Ayesha";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                   // Optional: Navigate to profile or open drawer when tapped
                   Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: colorExt.primary.withValues(alpha: 0.1),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                    style: TextStyle(color: colorExt.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $displayName!",
                    style: TextStyle(
                      color: colorExt.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Metropolis',
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: _showLocationPrompt,
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: colorExt.primary),
                        const SizedBox(width: 4),
                        Text(
                          "Main Blvd, Gulberg III", // In a real app, this is dynamic. Using static as placeholder.
                          style: TextStyle(
                            color: colorExt.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: colorExt.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Icon(Icons.menu_rounded, color: colorExt.primary, size: 28),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchPill() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchSelectionView()));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorExt.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AbsorbPointer(
            child: TextField(
              controller: txtSearch,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintText: "Search for Biryani, Karahi...",
                hintStyle: TextStyle(color: colorExt.placeholder, fontSize: 15),
                prefixIcon: Icon(Icons.search_rounded, color: colorExt.primary),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorExt.primaryContainer,
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.tune_rounded, color: colorExt.primary, size: 18),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 140, // Height for larger cards
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: catArr.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          var cObj = catArr[index] as Map? ?? {};
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchSelectionView(initialQuery: cObj["name"])));
            },
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (cObj["color"] as Color).withValues(alpha: 0.15),
                    // M3 Expressive: Asymmetrical shape (Leaf shape)
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Icon(cObj["icon"] as IconData, size: 32, color: cObj["color"]),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .scale(duration: 800.ms, curve: Curves.easeInOut, begin: const Offset(1,1), end: const Offset(1.05, 1.05)),
                const SizedBox(height: 12),
                Text(
                  cObj["name"],
                  style: TextStyle(
                    color: colorExt.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                  ),
                ),
              ],
            ),
          ).animate(delay: (index * 100).ms).slideX(begin: 0.2, curve: Curves.easeOutBack);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onStatsTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorExt.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5
            ),
          ),
          InkWell(
            onTap: onStatsTap,
            child: Text(
              "See all",
              style: TextStyle(
                color: colorExt.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ),
        ],
      ),
    );
  }
}
