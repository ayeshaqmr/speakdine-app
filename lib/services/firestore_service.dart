
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakdine_app/models/menu_item_model.dart';
import 'package:speakdine_app/models/category_model.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:speakdine_app/services/storage_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  String get _uid => _auth.currentUser?.uid ?? '';

  Stream<List<Map<String, dynamic>>> streamRestaurants() {
    return _db.collection('restaurants').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> streamRestaurantsByCategory(String category) {
    return _db.collection('restaurants')
      .where('categories', arrayContains: category)
      .snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
  }

  Stream<List<Map<String, dynamic>>> streamTrendingRestaurants() {
    return _db.collection('restaurants')
      .where('is_trending', isEqualTo: true)
      .limit(10)
      .snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
  }

  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    final snapshot = await _db.collection('restaurants')
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThanOrEqualTo: '$query\uf8ff')
      .get();
    
    return snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // --- CATEGORY MANAGEMENT ---

  Future<void> addCategory(CategoryModel category) async {
    if (_uid.isEmpty) throw Exception("User not logged in");
    
    await _db.collection('categories').add({
      ...category.toMap(),
      'restaurant_id': _uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<CategoryModel>> streamCategories() {
    if (_uid.isEmpty) return const Stream.empty();

    return _db
        .collection('categories')
        .where('restaurant_id', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // PUBLIC: For customers to see categories of a specific restaurant
  Stream<List<CategoryModel>> streamCategoriesForRestaurant(String restaurantId) {
    return _db
        .collection('categories')
        .where('restaurant_id', isEqualTo: restaurantId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection('categories').doc(category.id).update({
      ...category.toMap(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String categoryId) async {
     await _db.collection('categories').doc(categoryId).delete();
  }

  // --- MENU MANAGEMENT ---

  Future<void> addMenuItem(MenuItemModel item, File? imageFile) async {
    if (_uid.isEmpty) throw Exception("User not logged in");

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _storageService.uploadImage(imageFile, 'menu_items/$_uid');
    }

    item.imageUrl = imageUrl;
    
    // We add the restaurant ID to the menu item so we can query it later
    // In a real app, you might have a subcollection structure or a 'restaurantId' field
    // For simplicity, we'll use a top-level collection 'menu_items' with a 'restaurantId' field.
    
    await _db.collection('menu_items').add({
      ...item.toJson(),
      'restaurant_id': _uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MenuItemModel>> streamMenuItems() {
    if (_uid.isEmpty) return const Stream.empty();

    return _db
        .collection('menu_items')
        .where('restaurant_id', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return MenuItemModel.fromJson(data);
      }).toList();
    });
  }

  // PUBLIC: For customers to see items of a specific restaurant
  Stream<List<MenuItemModel>> streamMenuItemsForRestaurant(String restaurantId) {
    return _db
        .collection('menu_items')
        .where('restaurant_id', isEqualTo: restaurantId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return MenuItemModel.fromJson(data);
      }).toList();
    });
  }


  Future<void> updateMenuItemAvailability(String itemId, bool isAvailable) async {
    await _db.collection('menu_items').doc(itemId).update({
      'is_available': isAvailable,
    });
  }

  Future<void> updateMenuItem(MenuItemModel item, File? imageFile) async {
    if (_uid.isEmpty) throw Exception("User not logged in");

    String? imageUrl = item.imageUrl;
    if (imageFile != null) {
      imageUrl = await _storageService.uploadImage(imageFile, 'menu_items/$_uid');
    }

    await _db.collection('menu_items').doc(item.id).update({
      ...item.toJson(),
      'image_url': imageUrl,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _db.collection('menu_items').doc(itemId).delete();
  }

  // --- ORDER MANAGEMENT ---

  Future<String> placeOrder(OrderModel order, String restaurantId) async {
    if (_uid.isEmpty) throw Exception("User not logged in");
    
    final docRef = await _db.collection('orders').add({
      ...order.toJson(restaurantId),
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<List<OrderModel>> streamOrdersForCustomer() {
    if (_uid.isEmpty) return const Stream.empty();

    return _db.collection('orders')
        .where('user_id', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
           return snapshot.docs.map((doc) {
             var data = doc.data();
             data['id'] = doc.id;
             return OrderModel.fromJson(data);
           }).toList();
        });
  }

  Stream<List<OrderModel>> streamOrders() {
     // Assuming orders have a 'restaurant_id' field
     // If orders are created by customers, they must include this field.
     if (_uid.isEmpty) return const Stream.empty();

     return _db.collection('orders')
        .where('restaurant_id', isEqualTo: _uid) // Filter by my restaurant
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
           return snapshot.docs.map((doc) {
             var data = doc.data();
             data['id'] = doc.id;
             return OrderModel.fromJson(data);
           }).toList();
        });
  }
  
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
     await _db.collection('orders').doc(orderId).update({
       'status': status.toString().split('.').last,
     });
  }

  // Temporary helper to create a dummy order for testing
  Future<void> createDummyOrder() async {
    if (_uid.isEmpty) return;
    
    await _db.collection('orders').add({
      'restaurant_id': _uid,
      'user_id': 'test_user',
      'user_name': 'Test Customer',
      'total_amount': 1550,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
      'items': [
        {
          'name': 'Test Burger',
          'description': 'Description',
          'price': 450, 
          'is_available': true
        },
        {
          'name': 'Test Pizza',
          'description': 'Description',
          'price': 1100, 
          'is_available': true
        }
      ]
    });
  }

  // --- REVIEWS & REPLIES ---

  Stream<List<Map<String, dynamic>>> streamReviewsForRestaurant(String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> addReplyToReview(String restaurantId, String reviewId, String replyText) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .doc(reviewId)
        .update({
      'reply': replyText,
      'repliedAt': FieldValue.serverTimestamp(),
    });
  }
}
