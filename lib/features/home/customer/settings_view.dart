import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class CustomerSettingsView extends StatefulWidget {
  const CustomerSettingsView({super.key});

  @override
  State<CustomerSettingsView> createState() => _CustomerSettingsViewState();
}

class _CustomerSettingsViewState extends State<CustomerSettingsView> {
  bool _notificationsEnabled = true;
  bool _locationSharing = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Metropolis', color: colorExt.primaryText)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSection(
              "Account Security",
              [
                _buildSettingTile("Change Password", Icons.lock_outline_rounded, () {}),
                _buildSettingTile("Two-Factor Authentication", Icons.security_rounded, () {}),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              "Preferences",
              [
                _buildSwitchTile("Push Notifications", Icons.notifications_active_outlined, _notificationsEnabled, (v) {
                  setState(() => _notificationsEnabled = v);
                }),
                _buildSwitchTile("Location Services", Icons.location_on_outlined, _locationSharing, (v) {
                  setState(() => _locationSharing = v);
                }),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              "App Info",
              [
                _buildSettingTile("Terms of Service", Icons.description_outlined, () {}),
                _buildSettingTile("Privacy Policy", Icons.privacy_tip_outlined, () {}),
                _buildSettingTile("App Version", Icons.info_outline_rounded, () {}, trailing: const Text("1.0.0", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSettingTile(String title, IconData icon, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: colorExt.primary, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colorExt.primaryText)),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: colorExt.placeholder, size: 20),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      secondary: Icon(icon, color: colorExt.primary, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colorExt.primaryText)),
      activeThumbColor: colorExt.primary,
    );
  }
}
