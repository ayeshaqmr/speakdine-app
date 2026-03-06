import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/models/menu_item_model.dart';
import 'package:speakdine_app/features/home/restaurant/add_menu_item_view.dart';
import 'package:speakdine_app/features/home/restaurant/category_management_view.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/widgets/custom_popups.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class MenuManagementView extends StatefulWidget {
  const MenuManagementView({super.key});

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildMenuGrid(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMenuItemView()));
        },
        label: const Text("Add New Item", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: colorExt.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: colorExt.surface,
      surfaceTintColor: Colors.transparent,
      leading: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryManagementView()),
            ),
            icon: const Icon(Icons.category_rounded, size: 20),
            label: const Text("Categories"),
            style: TextButton.styleFrom(
              foregroundColor: colorExt.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          "Menu Management",
          style: TextStyle(
            color: colorExt.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            fontFamily: 'Metropolis',
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return StreamBuilder<List<MenuItemModel>>(
      stream: _dbService.streamMenuItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError) {
           return SliverFillRemaining(child: Center(child: Text("Error: ${snapshot.error}")));
        }

        var menuItems = snapshot.data ?? [];

        if (menuItems.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 80, color: colorExt.placeholder.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "Your menu is empty",
                    style: TextStyle(color: colorExt.secondaryText, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ).animate().fadeIn().scale(),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var item = menuItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMenuItemCard(item, index),
                );
              },
              childCount: menuItems.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItemCard(MenuItemModel item, int index) {
    return Card(
      elevation: 0,
      color: colorExt.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddMenuItemView(menuItem: item))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null
                        ? Image.network(item.imageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                        : Container(
                            width: 100,
                            height: 100,
                            color: colorExt.secondaryContainer,
                            child: Icon(Icons.restaurant_rounded, color: colorExt.primary, size: 32),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.categoryId ?? "Dish",
                              style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                            ),
                            Switch.adaptive(
                              value: item.isAvailable, 
                              activeTrackColor: Colors.green,
                              onChanged: (val) => _dbService.updateMenuItemAvailability(item.id!, val),
                            ),
                          ],
                        ),
                        Text(
                          item.name,
                          style: TextStyle(
                            color: colorExt.primaryText,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rs. ${item.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: colorExt.secondaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      bool confirm = false;
                      await CustomPopups.showPremiumAlert(
                        context,
                        title: "Delete Item?",
                        message: "Are you sure you want to delete ${item.name}?",
                        onConfirm: () => confirm = true,
                      );
                      if (confirm && mounted) {
                        await _dbService.deleteMenuItem(item.id!);
                        PremiumSnackbar.show(context, message: "Item deleted");
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    label: const Text("Delete"),
                    style: TextButton.styleFrom(foregroundColor: colorExt.error),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddMenuItemView(menuItem: item))),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text("Edit Dish"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }
}
