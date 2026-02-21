import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/common/colorExtension.dart';

class RestaurantProfileView extends StatefulWidget {
  const RestaurantProfileView({super.key});

  @override
  State<RestaurantProfileView> createState() => _RestaurantProfileViewState();
}

class _RestaurantProfileViewState extends State<RestaurantProfileView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await _firestore.collection('restaurants').doc(user?.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['restaurantName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _descriptionController.text = data['description'] ?? '';
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await _firestore.collection('restaurants').doc(user?.uid).update({
        'restaurantName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully!"),
          backgroundColor: colorExt.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Restaurant Profile",
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorExt.primary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorExt.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 50,
                      color: colorExt.primary,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Form Fields
                  _buildTextField(
                    controller: _nameController,
                    label: "Restaurant Name",
                    icon: Icons.store,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _addressController,
                    label: "Address",
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _descriptionController,
                    label: "Description",
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorExt.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Save Changes",
                              style: TextStyle(
                                fontFamily: 'Metropolis',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Metropolis',
          color: colorExt.primaryText,
        ),
        prefixIcon: Icon(icon, color: colorExt.secondary),
        filled: true,
        fillColor: colorExt.textfield,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorExt.shadow, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorExt.primary, width: 2),
        ),
      ),
    );
  }
}

