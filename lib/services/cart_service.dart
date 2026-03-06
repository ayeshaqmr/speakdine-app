import 'package:flutter/foundation.dart';
import 'package:speakdine_app/models/menu_item_model.dart';

class CartItemModel {
  MenuItemModel menuItem;
  int quantity;

  CartItemModel({required this.menuItem, this.quantity = 1});

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
    };
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItemModel> _items = [];
  String? _currentRestaurantId;

  List<CartItemModel> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(MenuItemModel item, String restaurantId) {
    // If adding from a different restaurant, clear cart
    if (_currentRestaurantId != null && _currentRestaurantId != restaurantId) {
      _items.clear();
    }
    _currentRestaurantId = restaurantId;
    // Check if item already exists
    int index = _items.indexWhere((element) => element.menuItem.id == item.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel(menuItem: item));
    }
    notifyListeners();
  }
  void removeFromCart(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    if (_items.isEmpty) {
      _currentRestaurantId = null;
    }
    notifyListeners();
  }
  
  void deleteItem(CartItemModel item) {
    _items.remove(item);
    if (_items.isEmpty) {
      _currentRestaurantId = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentRestaurantId = null;
    notifyListeners();
  }
  
  String? get currentRestaurantId => _currentRestaurantId;
}