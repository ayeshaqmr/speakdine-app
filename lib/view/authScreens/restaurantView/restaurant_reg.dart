import 'package:flutter/material.dart';
import 'package:speak_dine/common/colorExtension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurant_auth.dart';

class RestaurantRegView extends StatefulWidget {
  const RestaurantRegView({super.key});

  @override
  State<RestaurantRegView> createState() => _RestaurantRegViewState();
}

class _RestaurantRegViewState extends State<RestaurantRegView> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);

      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save restaurant data to Firestore
      await _firestore.collection('restaurants').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'restaurantName': _restaurantNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'role': 'restaurant',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restaurant registered successfully!'),
          backgroundColor: colorExt.primary,
        ),
      );

      // Navigate back to login after registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantAuthView()),
      );

    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == 'weak-password') {
        message = "The password is too weak";
      } else if (e.code == 'email-already-in-use') {
        message = "An account already exists with this email";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
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
      appBar: AppBar(
        title: Text(
          "Restaurant Registration",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/speakdine_logo.png",
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Register Your Restaurant",
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: colorExt.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fill in the details to create your account",
                      style: TextStyle(
                        fontFamily: 'Metropolis',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorExt.primaryText,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Restaurant Name
                    _buildTextField(
                      controller: _restaurantNameController,
                      label: "Restaurant Name",
                      icon: Icons.restaurant_menu_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter restaurant name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Address
                    _buildTextField(
                      controller: _addressController,
                      label: "Restaurant Address",
                      icon: Icons.location_on_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Confirm Password
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: "Confirm Password",
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: colorExt.secondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // Register Button
                    SizedBox(
                      width: 250,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Btns(
                              text: "Register",
                              onPress: _register,
                            ),
                    ),
                    const SizedBox(height: 15),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontFamily: 'Metropolis',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorExt.primaryText,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Login",
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 350,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 16,
            color: colorExt.secondary,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
