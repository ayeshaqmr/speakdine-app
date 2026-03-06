import 'package:flutter/material.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class RestaurantSettingsView extends StatefulWidget {
  const RestaurantSettingsView({super.key});

  @override
  State<RestaurantSettingsView> createState() => _RestaurantSettingsViewState();
}

class _RestaurantSettingsViewState extends State<RestaurantSettingsView> {
  double _deliveryRadius = 5.0;
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);
  bool _acceptingOrders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
       appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("Operational State"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: SwitchListTile.adaptive(
                title: const Text("Accepting Orders", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                subtitle: Text("Toggle to pause incoming orders temporarily", style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w600, fontSize: 12)),
                value: _acceptingOrders,
                activeTrackColor: Colors.green,
                onChanged: (val) => setState(() => _acceptingOrders = val),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionLabel("Business Hours"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: Column(
                children: [
                  _buildTimePicker("Opening Time", _openTime, (t) => setState(() => _openTime = t)),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildTimePicker("Closing Time", _closeTime, (t) => setState(() => _closeTime = t)),
                ],
              )
            ),

            const SizedBox(height: 32),
            _buildSectionLabel("Delivery Configuration"),
            const SizedBox(height: 12),
            _buildSettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Service Radius", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: colorExt.primaryContainer, borderRadius: BorderRadius.circular(12)),
                          child: Text("${_deliveryRadius.toStringAsFixed(1)} km", style: TextStyle(color: colorExt.primary, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: _deliveryRadius,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    activeColor: colorExt.primary,
                    inactiveColor: colorExt.primary.withValues(alpha: 0.1),
                    onChanged: (val) => setState(() => _deliveryRadius = val),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text("Set the maximum distance for active deliveries.", style: TextStyle(color: colorExt.secondaryText, fontSize: 12, fontWeight: FontWeight.w600)),
                  )
                ],
              )
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                   Navigator.pop(context);
                },
                child: const Text("SAVE SETTINGS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: colorExt.primary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Card(
      elevation: 0,
      color: colorExt.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorExt.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(time.format(context), style: TextStyle(fontWeight: FontWeight.w900, color: colorExt.primary, fontSize: 14)),
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null && picked != time) {
          onTimeChanged(picked);
        }
      },
    );
  }
}
