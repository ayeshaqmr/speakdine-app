import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:speak_dine/config/api_keys.dart';

class SavedCard {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });
}

class PaymentService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$stripeServerUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        debugPrint('[PaymentService] $path failed: ${response.body}');
        return null;
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[PaymentService] $path error: $e');
      return null;
    }
  }

  /// Ensures the user has a Stripe Customer ID.
  /// Creates one if it doesn't exist, stores it in Firestore.
  static Future<String?> ensureStripeCustomer({
    required String userId,
    required String email,
    String? name,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final existingId = userDoc.data()?['stripeCustomerId'] as String?;

    if (existingId != null && existingId.isNotEmpty) return existingId;

    final result = await _post('/create-customer', {
      'userId': userId,
      'email': email,
      'name': name,
    });

    if (result == null) return null;

    final customerId = result['customerId'] as String?;
    if (customerId != null) {
      await _firestore.collection('users').doc(userId).update({
        'stripeCustomerId': customerId,
      });
    }

    return customerId;
  }

  /// Creates a Stripe Checkout Session and opens it in the browser.
  /// Returns the session ID if successful.
  static Future<String?> openCheckout({
    required String? stripeCustomerId,
    required List<Map<String, dynamic>> items,
    required String orderId,
  }) async {
    final lineItems = items.map((item) => {
          'name': item['name'] as String? ?? 'Item',
          'quantity': item['quantity'] as int? ?? 1,
          'priceInPaisa': ((item['price'] as num? ?? 0) * 100).round(),
        }).toList();

    final result = await _post('/create-checkout-session', {
      'customerId': stripeCustomerId,
      'items': lineItems,
      'orderId': orderId,
      'currency': 'pkr',
    });

    if (result == null) return null;

    final url = result['url'] as String?;
    final sessionId = result['sessionId'] as String?;

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return sessionId;
  }

  /// Opens Stripe Checkout in setup mode to save a card.
  static Future<bool> openCardSetup({
    required String stripeCustomerId,
  }) async {
    final result = await _post('/create-setup-session', {
      'customerId': stripeCustomerId,
    });

    if (result == null) return false;

    final url = result['url'] as String?;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    }

    return false;
  }

  /// Retrieves saved cards for a Stripe Customer.
  static Future<List<SavedCard>> getSavedCards({
    required String stripeCustomerId,
  }) async {
    final result = await _post('/get-saved-cards', {
      'customerId': stripeCustomerId,
    });

    if (result == null) return [];

    final cardsJson = result['cards'] as List<dynamic>? ?? [];
    return cardsJson
        .map((c) => SavedCard(
              id: c['id'] as String,
              brand: c['brand'] as String,
              last4: c['last4'] as String,
              expMonth: c['expMonth'] as int,
              expYear: c['expYear'] as int,
            ))
        .toList();
  }

  /// Deletes a saved card.
  static Future<bool> deleteSavedCard({
    required String paymentMethodId,
  }) async {
    final result = await _post('/delete-saved-card', {
      'paymentMethodId': paymentMethodId,
    });

    return result?['success'] == true;
  }

  /// Charges a saved card directly (for voice-command payments).
  static Future<bool> chargeWithSavedCard({
    required String stripeCustomerId,
    required String paymentMethodId,
    required double amount,
    required String orderId,
  }) async {
    final result = await _post('/charge-saved-card', {
      'customerId': stripeCustomerId,
      'paymentMethodId': paymentMethodId,
      'amountInPaisa': (amount * 100).round(),
      'orderId': orderId,
      'currency': 'pkr',
    });

    return result?['success'] == true;
  }
}
