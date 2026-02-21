import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/view/authScreens/restaurantView/restaurant_auth.dart';
import 'package:speak_dine/view/authScreens/userView/user_auth.dart';

class SelectRoleView extends StatefulWidget {
  const SelectRoleView({super.key});

  @override
  State<SelectRoleView> createState() => _SelectRoleViewState();
}

class _SelectRoleViewState extends State<SelectRoleView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
            Image.asset(
              "assets/startup_bg.png",
              width: media.width,
              height: media.height,
              fit: BoxFit.cover,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 300),
                  Text(
                    "Select Your Role",
                    style: TextStyle(
                      fontFamily: 'Metropolis',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: colorExt.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: colorExt.container,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          color: colorExt.shadow,
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Choose how you want to continue as:",
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorExt.primaryText,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Btns(
                          text: "Customer",
                          icon: Icons.person_rounded,
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const UserAuthView()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Btns(
                          text: "Restaurant",
                          icon: Icons.restaurant_menu_rounded,
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RestaurantAuthView()),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Need Help?",
                            style: TextStyle(
                              fontFamily: 'Metropolis',
                              fontSize: 16,
                              color: colorExt.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Btns extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPress;

  const Btns({ super.key, required this.text, required this.icon, required this.onPress,});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorExt.primarylight,
          foregroundColor: colorExt.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ).copyWith(
          overlayColor: MaterialStatePropertyAll(
            colorExt.primaryopacity,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 9),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}