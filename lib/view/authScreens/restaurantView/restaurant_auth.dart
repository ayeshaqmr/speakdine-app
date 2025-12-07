import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'restaurant_reg.dart';

class RestaurantAuthView extends StatelessWidget {
  const RestaurantAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text(
        "Restaurant Login",
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colorExt.primary,
        ),
      )
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/app_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Expanded(child: SingleChildScrollView(
            child: Column(
              children: [
                _login(context),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}

Widget _login(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        "assets/speakdine_logo.png",
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      ),
      Text(
        "Welcome!",
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorExt.primary,
        ),
      ),
      SizedBox(height: 25),
      Text(
        "Enter your restaurant credentials to login",
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorExt.primaryText,
        ),
      ),

      SizedBox(height: 15),

      SizedBox(
        width: 350,
        child: TextField(
          decoration: InputDecoration(
            labelText: "Restaurant Name",
            floatingLabelStyle: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 16,
              color: colorExt.secondary,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            prefixIcon: const Icon(Icons.restaurant_menu_rounded),
            filled: true,
            fillColor: colorExt.textfield,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: colorExt.shadow,
                width: 1.5,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: colorExt.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ),

      SizedBox(height: 15),

      SizedBox(
        width: 350,
        child: TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            floatingLabelStyle: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 16,
              color: colorExt.secondary,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            prefixIcon: const Icon(Icons.lock_rounded),
            filled: true,
            fillColor: colorExt.textfield,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: colorExt.shadow,
                width: 1.5,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: colorExt.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ),

      SizedBox(height: 20),

      SizedBox(
        width: 200,
        child: Btns(
          text: "Login",
          onPress: () {

          },
        ),
      ),

      SizedBox(height: 15),

      SizedBox(
        width: 200,
        child: TextButton(
          onPressed: () {},
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              fontFamily: 'Metropolis',
              fontSize: 16,
              color: colorExt.secondary,
            ),
          ),
        ),
      ),

      SizedBox(height: 00),

      SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Restaurant Not Registered?",
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorExt.primaryText,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RestaurantAuthView()),
                );
              },
              child: Text(
                "Register",
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorExt.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


class Btns extends StatelessWidget {
  final String text;
  final VoidCallback onPress;

  const Btns({ super.key, required this.text, required this.onPress,});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorExt.primary,
          foregroundColor: colorExt.primarylight,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(
            colorExt.primaryopacity,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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