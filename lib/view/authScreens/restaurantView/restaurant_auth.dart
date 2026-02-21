import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:speak_dine/view/home/restaurant_home.dart';
import 'restaurant_reg.dart';

class RestaurantAuthView extends StatefulWidget {
  const RestaurantAuthView({super.key});

  @override
  State<RestaurantAuthView> createState() => _RestaurantAuthViewState();
}

class _RestaurantAuthViewState extends State<RestaurantAuthView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print("=== LOGIN BUTTON PRESSED ===");
    print("Email: ${_emailController.text}");
    print("Password length: ${_passwordController.text.length}");
    
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      print("Empty fields detected");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _loading = true);
      print("Attempting Firebase login...");

      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("Login SUCCESS!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login successful!"),
          backgroundColor: colorExt.primary,
        ),
      );

      // Navigate to restaurant dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantHomeView()),
      );

    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      String message = "Login failed";
      if (e.code == 'user-not-found') {
        message = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid email or password";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("General error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _loading = false);
  }

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
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              floatingLabelStyle: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 16,
                color: colorExt.secondary,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              prefixIcon: const Icon(Icons.email_rounded),
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
            controller: _passwordController,
            obscureText: _obscurePassword,
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
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: colorExt.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Btns(
                  text: "Login",
                  onPress: _login,
                ),
        ),

        SizedBox(height: 15),

        SizedBox(
          width: 200,
          child: TextButton(
            onPressed: () {
              // TODO: Implement forgot password
            },
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
                    MaterialPageRoute(builder: (_) => const RestaurantRegView()),
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
