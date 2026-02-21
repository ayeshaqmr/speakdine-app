import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_dine/view/authScreens/login_view.dart';

class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

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
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final doc =
          await _firestore.collection('users').doc(_user?.uid).get();
      if (doc.exists) {
        final profile = doc.data()!;
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? _user?.email ?? '';
        _phoneController.text = profile['phone'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await _firestore.collection('users').doc(_user?.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      showAppToast(context, 'Profile updated successfully');
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Something went wrong. Please try again later.');
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Skeletonizer(
      enabled: _loading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile').h4().semiBold(),
            const Text('Manage your account details')
                .muted()
                .small(),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(RadixIcons.person,
                    size: 36, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 32),
            _labeledField('Name', _nameController, 'Your name'),
            _labeledField('Email', _emailController, 'Email address'),
            _labeledField('Phone', _phoneController, 'Phone number'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _saving
                  ? Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : PrimaryButton(
                      onPressed: _saveProfile,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Save Changes')],
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlineButton(
                onPressed: _logout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RadixIcons.exit,
                        size: 16, color: theme.colorScheme.destructive),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style:
                          TextStyle(color: theme.colorScheme.destructive),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label).semiBold().small(),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            placeholder: Text(placeholder),
          ),
        ],
      ),
    );
  }
}
