import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:speakdine_app/models/restaurant_model.dart';
import 'package:speakdine_app/services/storage_service.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<String?> saveRestaurantVerification({
    required String userId,
    required String email,
    required String restaurantName,
    required String phoneNumber,
    required String province,
    required String city,
    File? profilePictureUrl,
    required RestaurantData restaurantData,
  }) async {
    try {
      String? imageUrl;
      if (profilePictureUrl != null) {
        imageUrl = await _storageService.uploadImage(
          profilePictureUrl,
          'restaurant_profiles/$userId',
        );
      }

      // Convert RestaurantData to Map
      final data = restaurantData.toMap();
      
      // Add extra fields
      data['email'] = email;
      data['username'] = restaurantName; // Using restaurant name as username for login lookup
      data['profile_picture'] = imageUrl;
      data['created_at'] = FieldValue.serverTimestamp();
      data['user_type'] = 'restaurant';
      
      // Save to 'restaurants' collection with user ID
      await _firestore.collection('restaurants').doc(userId).set(data);
      
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Fetch restaurant details
  Future<RestaurantData?> getRestaurantProfile(String userId) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(userId).get();
      if (doc.exists) {
        return RestaurantData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }
}