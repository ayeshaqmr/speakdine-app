import 'package:flutter/material.dart';
import 'package:speakdine_app/features/splash/splash_screen.dart';
import 'package:speakdine_app/features/onboarding/onboarding_screen.dart';
import 'package:speakdine_app/features/home/customer/customer_home.dart';
import 'package:speakdine_app/features/home/restaurant/restaurant_home.dart';
import 'package:speakdine_app/features/auth/views/restaurant_registration_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String customerHome = '/customer-home';
  static const String restaurantHome = '/restaurant-home';
  static const String restaurantSignup = '/restaurant-signup';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    customerHome: (context) => const CustomerHome(),
    restaurantHome: (context) => const RestaurantHome(),
    restaurantSignup: (context) => const RestaurantRegistrationView(),
  };
}
