import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'restaurant_detail_view.dart';

class SearchSelectionView extends StatefulWidget {
  final String? initialQuery;
  const SearchSelectionView({super.key, this.initialQuery});

  @override
  State<SearchSelectionView> createState() => _SearchSelectionViewState();
}

class _SearchSelectionViewState extends State<SearchSelectionView> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

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

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _dbService.searchRestaurants(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery == null,
          onChanged: (val) => _performSearch(val),
          decoration: InputDecoration(
            hintText: "Search restaurants...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorExt.placeholder),
          ),
          style: TextStyle(fontWeight: FontWeight.w700, color: colorExt.primaryText),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black54),
              onPressed: () {
                _searchController.clear();
                _performSearch("");
              },
            ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colorExt.primary),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
      body: _isSearching 
        ? const Center(child: CircularProgressIndicator())
        : _results.isEmpty 
          ? _buildEmptyState()
          : _buildResultsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: colorExt.placeholder.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty ? "Search for delicious food" : "No restaurants found",
            style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final restaurant = _results[index];
        return _buildRestaurantTile(restaurant, index);
      },
    );
  }

  Widget _buildRestaurantTile(Map<String, dynamic> restaurant, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RestaurantDetailView(restaurantObj: restaurant)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: _parseColor(restaurant['color']),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Center(child: Icon(Icons.storefront_rounded, size: 50, color: Colors.white54)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant['name'] ?? "Unnamed",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorExt.primaryText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${restaurant['food_type'] ?? 'Desi'} • ${restaurant['type'] ?? 'Restaurant'}",
                          style: TextStyle(color: colorExt.secondaryText, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['rate']?.toString() ?? "4.5",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).slideY(begin: 0.2, curve: Curves.easeOutBack).fadeIn();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filters", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            const Text("Sort by", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                _filterChip("Rating"),
                _filterChip("Fast Delivery"),
                _filterChip("Price: Low to High"),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: colorExt.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: colorExt.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
