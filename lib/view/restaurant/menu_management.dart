import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:flutter/material.dart' show FloatingActionButton;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _menuCategories = [
  'Appetizers',
  'Bakery',
  'BBQ & Grills',
  'Beverages',
  'Biryani & Rice',
  'Breakfast',
  'Burgers',
  'Chinese',
  'Desi',
  'Desserts',
  'Fast Food',
  'Healthy',
  'Italian',
  'Japanese',
  'Mexican',
  'Pasta',
  'Pizza',
  'Salads',
  'Sandwiches',
  'Seafood',
  'Sides',
  'Soups',
  'Steaks',
  'Sushi',
  'Thai',
  'Wraps',
  'Other',
];

class MenuManagementView extends StatefulWidget {
  const MenuManagementView({super.key});

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu').h4().semiBold(),
                  const Text('Add, edit, or remove your dishes')
                      .muted()
                      .small(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('restaurants')
                          .doc(user?.uid)
                          .collection('menu')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildMenuSkeleton();
                        }
                        if (snapshot.hasError) {
                          debugPrint('[MenuManagement] Menu stream error: ${snapshot.error}');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              showAppToast(context, 'Unable to load menu. Please try again.');
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
                                const Text('Unable to load menu').semiBold(),
                              ],
                            ),
                          );
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(RadixIcons.reader,
                                    size: 48,
                                    color:
                                        theme.colorScheme.mutedForeground),
                                const SizedBox(height: 16),
                                const Text('No menu items yet').semiBold(),
                                const SizedBox(height: 8),
                                const Text('Tap + to add your first item')
                                    .muted()
                                    .small(),
                              ],
                            ),
                          );
                        }
                        final items = snapshot.data!.docs;
                        return ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index].data()
                                as Map<String, dynamic>;
                            final itemId = items[index].id;
                            return _buildMenuItem(theme, item, itemId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showAddItemDialog(theme),
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.add,
                color: theme.colorScheme.primaryForeground),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSkeleton() {
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Bone.text(words: 2),
                        const SizedBox(height: 8),
                        const Bone.text(words: 4, fontSize: 12),
                        const SizedBox(height: 8),
                        const Bone.text(words: 1),
                      ],
                    ),
                  ),
                  const Bone.icon(),
                  const SizedBox(width: 8),
                  const Bone.icon(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      ThemeData theme, Map<String, dynamic> item, String itemId) {
    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(RadixIcons.reader,
                size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? 'Item').semiBold(),
                if (item['description'] != null &&
                    item['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).muted().small(),
                ],
                const SizedBox(height: 2),
                Text(
                  '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GhostButton(
            density: ButtonDensity.icon,
            onPressed: () => _showEditItemDialog(theme, item, itemId),
            child: const Icon(RadixIcons.pencil1, size: 16),
          ),
          GhostButton(
            density: ButtonDensity.icon,
            onPressed: () => _deleteItem(itemId),
            child: Icon(RadixIcons.trash,
                size: 16, color: theme.colorScheme.destructive),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(ThemeData theme) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Menu Item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                      controller: nameController,
                      placeholder: const Text('Item name')),
                  const SizedBox(height: 12),
                  const Text('Description').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                      controller: descController,
                      placeholder: const Text('Description')),
                  const SizedBox(height: 12),
                  const Text('Price').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                      controller: priceController,
                      placeholder: const Text('0.00')),
                  const SizedBox(height: 12),
                  const Text('Category').semiBold().small(),
                  const SizedBox(height: 6),
                  Select<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value);
                    },
                    itemBuilder: (context, item) => Text(item),
                    placeholder: const Text('Select a category'),
                    popupConstraints: const BoxConstraints(maxHeight: 300),
                    popup: SelectPopup(
                      searchFilter: (item, query) =>
                          item.toLowerCase().contains(query.toLowerCase()),
                      items: SelectItemList(
                        children: _menuCategories
                            .map((cat) => SelectItemButton(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () {
                _addItem(
                  nameController.text,
                  descController.text,
                  double.tryParse(priceController.text) ?? 0,
                  selectedCategory ?? '',
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(
      ThemeData theme, Map<String, dynamic> item, String itemId) {
    final nameController = TextEditingController(text: item['name']);
    final descController =
        TextEditingController(text: item['description']);
    final priceController =
        TextEditingController(text: item['price']?.toString());
    String? selectedCategory = item['category'] as String?;
    if (selectedCategory != null &&
        selectedCategory.isNotEmpty &&
        !_menuCategories.contains(selectedCategory)) {
      selectedCategory = 'Other';
    }
    if (selectedCategory?.isEmpty ?? true) selectedCategory = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Menu Item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                      controller: nameController,
                      placeholder: const Text('Item name')),
                  const SizedBox(height: 12),
                  const Text('Description').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                      controller: descController,
                      placeholder: const Text('Description')),
                  const SizedBox(height: 12),
                  const Text('Price').semiBold().small(),
                  const SizedBox(height: 6),
                  TextField(
                      controller: priceController,
                      placeholder: const Text('0.00')),
                  const SizedBox(height: 12),
                  const Text('Category').semiBold().small(),
                  const SizedBox(height: 6),
                  Select<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value);
                    },
                    itemBuilder: (context, item) => Text(item),
                    placeholder: const Text('Select a category'),
                    popupConstraints: const BoxConstraints(maxHeight: 300),
                    popup: SelectPopup(
                      searchFilter: (item, query) =>
                          item.toLowerCase().contains(query.toLowerCase()),
                      items: SelectItemList(
                        children: _menuCategories
                            .map((cat) => SelectItemButton(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () {
                _updateItem(
                  itemId,
                  nameController.text,
                  descController.text,
                  double.tryParse(priceController.text) ?? 0,
                  selectedCategory ?? '',
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem(
      String name, String description, double price, String category) async {
    if (name.isEmpty) {
      showAppToast(context, 'Item name is required');
      return;
    }
    try {
      await _firestore
          .collection('restaurants')
          .doc(user?.uid)
          .collection('menu')
          .add({
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      showAppToast(context, '$name added to menu');
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Something went wrong. Please try again later.');
    }
  }

  Future<void> _updateItem(String itemId, String name, String description,
      double price, String category) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(user?.uid)
          .collection('menu')
          .doc(itemId)
          .update({
        'name': name,
        'description': description,
        'price': price,
        'category': category,
      });
      if (!mounted) return;
      showAppToast(context, '$name updated');
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Something went wrong. Please try again later.');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          DestructiveButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore
            .collection('restaurants')
            .doc(user?.uid)
            .collection('menu')
            .doc(itemId)
            .delete();
        if (!mounted) return;
        showAppToast(context, 'Item deleted');
      } catch (e) {
        if (!mounted) return;
        showAppToast(context, 'Something went wrong. Please try again later.');
      }
    }
  }
}
