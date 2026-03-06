import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/features/home/customer/restaurant_detail_view.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  // Placeholder data for favorites
  final List<Map<String, dynamic>> _favorites = [
    {
      "id": "1",
      "name": "The Burger Bar",
      "category": "Fast Food",
      "rating": 4.8,
      "deliveryTime": "15-25 min",
      "image": "assets/food_placeholder.jpg" 
    },
    {
      "id": "2",
      "name": "Pizza Paradise",
      "category": "Italian",
      "rating": 4.5,
      "deliveryTime": "30-40 min",
      "image": "assets/pizza_placeholder.jpg"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Favorites",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'Metropolis'
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final restaurant = _favorites[index];
                return _buildFavoriteCard(restaurant, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 100, color: colorExt.placeholder.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            "No Favorites Yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colorExt.primaryText,
              fontFamily: 'Metropolis'
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the heart icon on a restaurant to save it here.",
            style: TextStyle(
              fontSize: 14,
              color: colorExt.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> restaurant, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RestaurantDetailView(restaurantObj: restaurant)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ]
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: colorExt.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Icon(Icons.restaurant_rounded, size: 50, color: colorExt.primary.withValues(alpha: 0.5)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant["name"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: colorExt.primaryText,
                          fontFamily: 'Metropolis'
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant["rating"]} • ${restaurant["category"]}",
                            style: TextStyle(
                              fontSize: 13,
                              color: colorExt.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                         _favorites.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                  )
                ],
              ),
            )
          ],
        ),
      ).animate(delay: (index * 100).ms).slideX(begin: 0.1).fadeIn(),
    );
  }
}
