import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/models/category_model.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class CategoryManagementView extends StatefulWidget {
  const CategoryManagementView({super.key});

  @override
  State<CategoryManagementView> createState() => _CategoryManagementViewState();
}

class _CategoryManagementViewState extends State<CategoryManagementView> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _categoryController = TextEditingController();

  void _showCategoryDialog({CategoryModel? category}) {
    if (category != null) {
      _categoryController.text = category.name;
    } else {
      _categoryController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          category == null ? "Add Category" : "Edit Category",
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: "Category Name",
            hintText: "e.g. Swets, Beverages, Mains",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          FilledButton(
            onPressed: () async {
              final name = _categoryController.text.trim();
              if (name.isEmpty) return;

              if (category == null) {
                await _dbService.addCategory(CategoryModel(name: name));
                if (mounted) PremiumSnackbar.show(context, message: "Category added");
              } else {
                await _dbService.updateCategory(category.copyWith(name: name));
                if (mounted) PremiumSnackbar.show(context, message: "Category updated");
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Manage Categories",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorExt.primary,
        foregroundColor: Colors.white,
      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
      body: StreamBuilder<List<CategoryModel>>(
        stream: _dbService.streamCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final categories = snapshot.data!;

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: colorExt.placeholder.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "No categories yet",
                    style: TextStyle(color: colorExt.secondaryText, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                elevation: 0,
                color: colorExt.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    cat.name,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: colorExt.primaryText),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showCategoryDialog(category: cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () async {
                          // In a real app, check if dishes exist first
                          await _dbService.deleteCategory(cat.id!);
                          if (mounted) PremiumSnackbar.show(context, message: "Category deleted");
                        },
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}
