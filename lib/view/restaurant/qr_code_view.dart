import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_dine/utils/toast_helper.dart';

class QRCodeView extends StatelessWidget {
  const QRCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final restaurantId = user?.uid ?? 'unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('QR Code').h4().semiBold(),
                const Text('Share this with your customers')
                    .muted()
                    .small(),
              ],
            ),
          ),
          const SizedBox(height: 40),
                Card(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        RadixIcons.viewGrid,
                        size: 120,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        restaurantId.substring(0, 8).toUpperCase(),
                        style: TextStyle(
                          letterSpacing: 3,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ).small(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Your Restaurant QR Code').semiBold(),
                const SizedBox(height: 8),
                const Text(
                  'Customers can scan this code to\nview your menu on their phone',
                  textAlign: TextAlign.center,
                ).muted().small(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      theme,
                      RadixIcons.download,
                      'Save',
                      () {
                        showAppToast(context, 'Save feature coming soon');
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildActionButton(
                      context,
                      theme,
                      RadixIcons.share1,
                      'Share',
                      () {
                        showAppToast(context, 'Share feature coming soon');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Card(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(RadixIcons.infoCircled,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          'Display this QR code at your restaurant entrance or on tables for easy menu access.',
                        ).muted().small(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label).muted().small(),
        ],
      ),
    );
  }
}
