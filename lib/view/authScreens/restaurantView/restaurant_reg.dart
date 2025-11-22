import 'package:flutter/material.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restaurant Dashboard")),
      body: const Center(
        child: Text(
          "Welcome Restaurant Owner!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}