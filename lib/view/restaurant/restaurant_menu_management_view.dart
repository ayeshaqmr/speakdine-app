import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/models/menu_item.dart';
import 'package:speak_dine/view/restaurant/add_menu_item_view.dart';

class RestaurantMenuManagementView extends StatefulWidget {
  const RestaurantMenuManagementView({super.key});

  @override
  State<RestaurantMenuManagementView> createState() => _RestaurantMenuManagementViewState();
}

class _RestaurantMenuManagementViewState extends State<RestaurantMenuManagementView> {
  List<MenuItemModel> menuItems = [
    MenuItemModel(
      id: '1',
      name: 'Margherita Pizza',
      description: 'Classic cheese and tomato base',
      price: 12.99,
      imageUrl: 'https://via.placeholder.com/150',
      isAvailable: true,
    ),
    MenuItemModel(
      id: '2',
      name: 'Pepperoni Pizza',
      description: 'Spicy pepperoni with mozzarella',
      price: 14.50,
      imageUrl: 'https://via.placeholder.com/150',
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(
          "Menu Management",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: colorExt.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorExt.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: menuItems.isEmpty
          ? Center(
              child: Text(
                "No menu items yet. Add some!",
                style: TextStyle(color: colorExt.secondaryText),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                var item = menuItems[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorExt.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.fastfood, color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.fastfood, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: colorExt.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorExt.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Rs. ${item.price.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: colorExt.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Switch(
                            value: item.isAvailable,
                            activeColor: colorExt.primary,
                            onChanged: (val) {
                              setState(() {
                                item.isAvailable = val;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colorExt.incorrect),
                            onPressed: () {
                              setState(() {
                                menuItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMenuItemView()));
        },
        label: const Text("Add New Item"),
        icon: const Icon(Icons.add),
        backgroundColor: colorExt.primary,
        elevation: 5,
      ),
    );
  }
}
