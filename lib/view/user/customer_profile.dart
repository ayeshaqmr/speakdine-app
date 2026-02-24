import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:speak_dine/utils/toast_helper.dart';
import 'package:speak_dine/widgets/location_picker.dart';
import 'package:speak_dine/services/image_upload_service.dart';
import 'package:speak_dine/services/payment_service.dart';
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
  bool _uploadingPhoto = false;
  bool _loadingCards = false;
  double? _lat;
  double? _lng;
  String _address = '';
  String? _photoUrl;
  String? _stripeCustomerId;
  List<SavedCard> _savedCards = [];

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
        _lat = (profile['lat'] as num?)?.toDouble();
        _lng = (profile['lng'] as num?)?.toDouble();
        _address = profile['address'] ?? '';
        _photoUrl = profile['photoUrl'] as String?;
        _stripeCustomerId = profile['stripeCustomerId'] as String?;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    if (mounted) setState(() => _loading = false);
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    if (_stripeCustomerId == null || _stripeCustomerId!.isEmpty) return;
    setState(() => _loadingCards = true);
    final cards = await PaymentService.getSavedCards(
        stripeCustomerId: _stripeCustomerId!);
    if (mounted) {
      setState(() {
        _savedCards = cards;
        _loadingCards = false;
      });
    }
  }

  Future<void> _addCard() async {
    final customerId = _stripeCustomerId ??
        await PaymentService.ensureStripeCustomer(
          userId: _user?.uid ?? '',
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
        );

    if (customerId == null) {
      if (mounted) showAppToast(context, 'Could not set up payment. Try again.', isError: true);
      return;
    }

    _stripeCustomerId = customerId;

    final opened = await PaymentService.openCardSetup(
        stripeCustomerId: customerId);
    if (opened && mounted) {
      showAppToast(context, 'Complete card setup in the opened page, then return here.');
    }
  }

  Future<void> _deleteCard(SavedCard card) async {
    final deleted =
        await PaymentService.deleteSavedCard(paymentMethodId: card.id);
    if (deleted) {
      setState(() => _savedCards.removeWhere((c) => c.id == card.id));
      if (mounted) showAppToast(context, 'Card removed');
    } else {
      if (mounted) showAppToast(context, 'Failed to remove card. Try again.', isError: true);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final file = await ImageUploadService.pickImage();
    if (file == null) return;

    setState(() => _uploadingPhoto = true);
    final url = await ImageUploadService.uploadProfileImage(
      userId: _user?.uid ?? '',
      imageFile: file,
    );
    if (url != null) {
      _photoUrl = url;
      await _firestore
          .collection('users')
          .doc(_user?.uid)
          .update({'photoUrl': url});
      if (mounted) showAppToast(context, 'Photo updated');
    } else {
      if (mounted) showAppToast(context, 'Photo upload failed. Please try again.', isError: true);
    }
    if (mounted) setState(() => _uploadingPhoto = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_lat != null && _lng != null) {
        data['lat'] = _lat;
        data['lng'] = _lng;
        data['address'] = _address;
      }
      if (_photoUrl != null) data['photoUrl'] = _photoUrl;
      await _firestore.collection('users').doc(_user?.uid).update(data);

      if (!mounted) return;
      showAppToast(context, 'Profile updated successfully');
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Something went wrong. Please try again later.', isError: true);
    }
    if (mounted) setState(() => _saving = false);
  }

  void _openLocationPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick Your Location'),
        content: SizedBox(
          width: 400,
          height: 450,
          child: LocationPicker(
            initialLat: _lat,
            initialLng: _lng,
            onLocationSelected: (lat, lng, address) {
              setState(() {
                _lat = lat;
                _lng = lng;
                _address = address;
              });
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
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
              child: GestureDetector(
                onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _uploadingPhoto
                          ? Center(
                              child: SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : _photoUrl != null && _photoUrl!.isNotEmpty
                              ? Image.network(
                                  _photoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    RadixIcons.person,
                                    size: 36,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : Icon(RadixIcons.person,
                                  size: 36, color: theme.colorScheme.primary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(RadixIcons.camera,
                            size: 14,
                            color: theme.colorScheme.primaryForeground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _labeledField('Name', _nameController, 'Your name'),
            _labeledField('Email', _emailController, 'Email address'),
            _labeledField('Phone', _phoneController, 'Phone number'),
            const SizedBox(height: 8),
            const Text('Delivery Location').semiBold().small(),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_address.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(RadixIcons.pinTop,
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).small(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlineButton(
                      onPressed: _openLocationPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(RadixIcons.crosshair1,
                              size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(_address.isEmpty
                              ? 'Set Location'
                              : 'Change Location'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSavedCardsSection(theme),
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

  Widget _buildSavedCardsSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(RadixIcons.cardStack,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Payment Methods').semiBold(),
              const Spacer(),
              GhostButton(
                density: ButtonDensity.compact,
                onPressed: _loadSavedCards,
                child: const Icon(RadixIcons.reload, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingCards)
            Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else if (_savedCards.isEmpty)
            Text('No saved cards yet').muted().small()
          else
            ..._savedCards.map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(RadixIcons.idCard,
                          size: 16, color: theme.colorScheme.foreground),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${card.brand.toUpperCase()} ···· ${card.last4}  (${card.expMonth}/${card.expYear})',
                        ).small(),
                      ),
                      GhostButton(
                        density: ButtonDensity.icon,
                        onPressed: () => _deleteCard(card),
                        child: Icon(RadixIcons.trash, size: 14,
                            color: theme.colorScheme.destructive),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlineButton(
              onPressed: _addCard,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RadixIcons.plus,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Add Card'),
                ],
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
