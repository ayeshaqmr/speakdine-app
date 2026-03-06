
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:image_picker/image_picker.dart';

import 'package:speakdine_app/models/menu_item_model.dart';
import 'package:speakdine_app/models/category_model.dart';
import 'package:speakdine_app/services/firestore_service.dart';

class AddMenuItemView extends StatefulWidget {
  final MenuItemModel? menuItem;
  const AddMenuItemView({super.key, this.menuItem});

  @override
  State<AddMenuItemView> createState() => _AddMenuItemViewState();
}

class _AddMenuItemViewState extends State<AddMenuItemView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _selectedCategoryId;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!.name;
      _descController.text = widget.menuItem!.description;
      _priceController.text = widget.menuItem!.price.toString();
      _selectedCategoryId = widget.menuItem!.categoryId;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if(_nameController.text.isEmpty || _priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and price')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      double price = double.tryParse(_priceController.text) ?? 0.0;
      MenuItemModel newItem = MenuItemModel(
        id: widget.menuItem?.id, // Keep ID if updating
        name: _nameController.text, 
        description: _descController.text, 
        price: price,
        categoryId: _selectedCategoryId,
        imageUrl: widget.menuItem?.imageUrl, // Keep existing URL if not changed
      );

      if (widget.menuItem != null) {
        await _dbService.updateMenuItem(newItem, _imageFile);
      } else {
        await _dbService.addMenuItem(newItem, _imageFile);
      }

      if(!mounted) return;
      Navigator.pop(context); // Go back after success
      
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving item: $e')),
      );
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.menuItem != null;

    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Dish" : "Add New Dish",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker - Expressive Card Style
            GestureDetector(
              onTap: _pickImage,
              child: Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                color: colorExt.surfaceContainerHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : (widget.menuItem?.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.menuItem!.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: (_imageFile == null && widget.menuItem?.imageUrl == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: colorExt.primary),
                            const SizedBox(height: 12),
                            Text(
                              "Add a mouth-watering photo",
                              style: TextStyle(
                                color: colorExt.secondaryText,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel("Dish Details"),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Dish Name",
                hintText: "e.g. Spicy Grilled Chicken",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Tell your customers about this dish...",
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel("Price & Category"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Price",
                      prefixText: "Rs. ",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: StreamBuilder<List<CategoryModel>>(
                    stream: _dbService.streamCategories(),
                    builder: (context, snapshot) {
                      var categories = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name, style: TextStyle(fontSize: 14, color: colorExt.primaryText)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategoryId = val),
                      );
                    }
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveItem,
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isEditing ? "UPDATE DISH" : "CREATE DISH",
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: colorExt.primary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }
}
