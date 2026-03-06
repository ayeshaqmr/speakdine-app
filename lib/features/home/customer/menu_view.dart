import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/services/cart_service.dart';
import 'package:speakdine_app/models/menu_item_model.dart';
import 'package:speakdine_app/models/category_model.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';
import 'cart_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final DatabaseService _dbService = DatabaseService();
  final CartService _cartService = CartService();
  String? _selectedRestaurantId;
  int _selectedFilterIndex = 0;

  final List<String> _filters = ["All", "Spicy", "BBQ", "Gravy", "Rice", "Sweet"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            _buildHeader().animate().shake(duration: 800.ms),
            const SizedBox(height: 20),
            _buildSearchBar().animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            _buildFilterChips().animate().slideX(begin: 0.2, delay: 300.ms, curve: Curves.easeOut),
            const SizedBox(height: 24),
            
            // Load Restaurants
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dbService.streamRestaurants(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var restaurants = snapshot.data!;
                if (restaurants.isEmpty) return const Center(child: Text("No restaurants found"));
                
                _selectedRestaurantId ??= restaurants.first['id'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Categories"),
                    const SizedBox(height: 16),
                    _buildCategoryList(),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle("Specialties"),
                    const SizedBox(height: 16),
                    _buildMenuItemList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Our",
                style: TextStyle(
                  color: colorExt.secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Menu",
                style: TextStyle(
                    color: colorExt.primaryText,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    fontFamily: 'Metropolis'),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))
                ]),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartView()));
              },
              icon: Icon(Icons.shopping_bag_outlined, size: 28, color: colorExt.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: colorExt.textField,
          borderRadius: BorderRadius.circular(28),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search for Chicken Tikka...",
            hintStyle: TextStyle(color: colorExt.placeholder, fontWeight: FontWeight.w500),
            prefixIcon: Icon(Icons.search_rounded, color: colorExt.secondaryText),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colorExt.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? colorExt.primary : colorExt.placeholder,
                  width: 1.5
                )
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : colorExt.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: TextStyle(
          color: colorExt.primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 120,
      child: StreamBuilder<List<CategoryModel>>(
        stream: _dbService.streamCategoriesForRestaurant(_selectedRestaurantId!),
        builder: (context, catSnapshot) {
          if (!catSnapshot.hasData) return const SizedBox();
          var categories = catSnapshot.data!;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              var cat = categories[index];
              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: colorExt.primaryContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8)
                      ),
                    ),
                    child: Icon(Icons.lunch_dining_rounded, color: colorExt.primary, size: 32),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: colorExt.primaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItemList() {
    return StreamBuilder<List<MenuItemModel>>(
      stream: _dbService.streamMenuItemsForRestaurant(_selectedRestaurantId!),
      builder: (context, itemSnapshot) {
        if (!itemSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        var items = itemSnapshot.data!;
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            var item = items[index];
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                    child: item.imageUrl != null
                        ? Image.network(item.imageUrl!, width: 120, height: 120, fit: BoxFit.cover)
                        : Container(
                            width: 120,
                            height: 120,
                            color: colorExt.secondaryContainer,
                            child: Icon(Icons.restaurant_rounded, color: colorExt.secondaryText, size: 40),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: colorExt.primaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(color: colorExt.secondaryText, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rs. ${item.price.toStringAsFixed(0)}",
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: colorExt.primary),
                              ),
                              InkWell(
                                onTap: () {
                                   _cartService.addToCart(item, _selectedRestaurantId!);
                                   PremiumSnackbar.show(context, message: "${item.name} added to cart");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: colorExt.primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ).animate(delay: (index * 100).ms).slideX(begin: 0.1, curve: Curves.easeOutBack);
          },
        );
      },
    );
  }
}
