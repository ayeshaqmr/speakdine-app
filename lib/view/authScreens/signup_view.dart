import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_dine/utils/toast_helper.dart';

enum AccountRole { customer, restaurant }

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AccountRole _selectedRole = AccountRole.customer;
  bool _loading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return _selectedRole == AccountRole.customer
          ? 'Please enter your name'
          : 'Please enter restaurant name';
    }
    if (_nameController.text.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (_emailController.text.trim().isEmpty) return 'Please enter email';
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      return 'Please enter a valid email';
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (_phoneController.text.trim().length < 10) {
      return 'Enter a valid phone number';
    }
    if (_selectedRole == AccountRole.restaurant &&
        _addressController.text.trim().isEmpty) {
      return 'Please enter address';
    }
    if (_passwordController.text.isEmpty) return 'Please enter password';
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    final error = _validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    try {
      setState(() => _loading = true);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      if (_selectedRole == AccountRole.customer) {
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('restaurants').doc(uid).set({
          'uid': uid,
          'restaurantName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'role': 'restaurant',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      _showMessage('Registered successfully! Please login.');
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to create account. Please try again.';
      if (e.code == 'weak-password') {
        message = 'Password is too weak. Please use a stronger one.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }
      _showMessage(message);
    } catch (_) {
      _showMessage('Something went wrong. Please wait and try again later.');
    }

    if (mounted) setState(() => _loading = false);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    showAppToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRestaurant = _selectedRole == AccountRole.restaurant;
    return Scaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/auth_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          SafeArea(
            child: Align(
              alignment: const Alignment(0, 0.0),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/speakdine_logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 380,
                      constraints: const BoxConstraints(maxHeight: 520),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.border
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child:
                                const Text('Fill in the details to get started')
                                    .muted()
                                    .small(),
                          ),
                          const SizedBox(height: 16),
                          _buildRoleToggle(theme),
                          const SizedBox(height: 20),
                        _labeledField(
                          isRestaurant ? 'Restaurant Name' : 'Full Name',
                          _nameController,
                          isRestaurant ? 'My Restaurant' : 'John Doe',
                        ),
                        _labeledField(
                            'Email', _emailController, 'you@example.com'),
                        _labeledField(
                            'Phone', _phoneController, '+1 234 567 8900'),
                        if (isRestaurant)
                          _labeledField('Address', _addressController,
                              '123 Main St, City'),
                        _labeledField('Password', _passwordController,
                            'Min. 6 characters',
                            obscure: true),
                        _labeledField('Confirm Password',
                            _confirmPasswordController, 'Re-enter password',
                            obscure: true),
                        const SizedBox(height: 8),
                        _loading
                            ? Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : PrimaryButton(
                                onPressed: _register,
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(RadixIcons.plusCircled, size: 16),
                                    SizedBox(width: 8),
                                    Text('Register'),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedRole = AccountRole.customer;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedRole == AccountRole.customer
                      ? theme.colorScheme.background
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedRole == AccountRole.customer
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.border
                                .withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RadixIcons.person,
                        size: 14,
                        color: _selectedRole == AccountRole.customer
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground),
                    const SizedBox(width: 6),
                    Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedRole == AccountRole.customer
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedRole = AccountRole.restaurant;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedRole == AccountRole.restaurant
                      ? theme.colorScheme.background
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedRole == AccountRole.restaurant
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.border
                                .withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RadixIcons.home,
                        size: 14,
                        color: _selectedRole == AccountRole.restaurant
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground),
                    const SizedBox(width: 6),
                    Text(
                      'Restaurant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedRole == AccountRole.restaurant
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController controller,
    String placeholder, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label).semiBold().small(),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            placeholder: Text(placeholder),
          ),
        ],
      ),
    );
  }
}
