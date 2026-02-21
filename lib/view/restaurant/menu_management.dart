import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Menu",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(),
        backgroundColor: colorExt.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add Item",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('restaurants')
            .doc(user?.uid)
            .collection('menu')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 80,
                    color: colorExt.shadow,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No menu items yet",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorExt.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tap + to add your first item",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 16,
                      color: colorExt.shadow,
                    ),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;
              final itemId = items[index].id;

              return _buildMenuItem(item, itemId);
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, String itemId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorExt.container,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorExt.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorExt.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fastfood_rounded,
              color: colorExt.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Item',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorExt.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 14,
                    color: colorExt.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item['price']?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    fontFamily: 'Metropolis',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorExt.secondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: colorExt.secondary),
                onPressed: () => _showEditItemDialog(item, itemId),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteItem(itemId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add Menu Item",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w700,
            color: colorExt.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(nameController, "Item Name", Icons.fastfood),
              const SizedBox(height: 15),
              _buildDialogTextField(descController, "Description", Icons.description),
              const SizedBox(height: 15),
              _buildDialogTextField(priceController, "Price", Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              _buildDialogTextField(categoryController, "Category (optional)", Icons.category),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colorExt.primaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              _addItem(
                nameController.text,
                descController.text,
                double.tryParse(priceController.text) ?? 0,
                categoryController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorExt.primary),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item, String itemId) {
    final nameController = TextEditingController(text: item['name']);
    final descController = TextEditingController(text: item['description']);
    final priceController = TextEditingController(text: item['price']?.toString());
    final categoryController = TextEditingController(text: item['category']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit Menu Item",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontWeight: FontWeight.w700,
            color: colorExt.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(nameController, "Item Name", Icons.fastfood),
              const SizedBox(height: 15),
              _buildDialogTextField(descController, "Description", Icons.description),
              const SizedBox(height: 15),
              _buildDialogTextField(priceController, "Price", Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              _buildDialogTextField(categoryController, "Category", Icons.category),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colorExt.primaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              _updateItem(
                itemId,
                nameController.text,
                descController.text,
                double.tryParse(priceController.text) ?? 0,
                categoryController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorExt.primary),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorExt.secondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorExt.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _addItem(String name, String description, double price, String category) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item name is required"), backgroundColor: Colors.red),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name added to menu!"), backgroundColor: colorExt.primary),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateItem(String itemId, String name, String description, double price, String category) async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name updated!"), backgroundColor: colorExt.primary),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted"), backgroundColor: Colors.orange),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}

