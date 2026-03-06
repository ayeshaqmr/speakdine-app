import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class CreateOfferView extends StatefulWidget {
  const CreateOfferView({super.key});

  @override
  State<CreateOfferView> createState() => _CreateOfferViewState();
}

class _CreateOfferViewState extends State<CreateOfferView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  
  Color _selectedColor = const Color(0xFFD32F2F); // Default Red
  final List<Color> _colors = [
    const Color(0xFFD32F2F), // Red
    const Color(0xFF388E3C), // Green
    const Color(0xFF1976D2), // Blue
    const Color(0xFFFBC02D), // Yellow
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFFE64A19), // Orange
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Create Promotion",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.close_rounded),
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
            // Preview Section
            _buildSectionLabel("PREVIEW"),
            const SizedBox(height: 16),
            _buildTicketPreview(),
            const SizedBox(height: 32),
            
            // Form Section
            _buildSectionLabel("DETAILS"),
            const SizedBox(height: 16),
            
            _buildTextField("Promotion Title", "e.g., Summer Sale", _titleController),
            const SizedBox(height: 16),
            _buildTextField("Description", "e.g., Get 50% off on all drinks", _descController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField("Discount Text", "e.g., 50% OFF", _discountController),
            
            const SizedBox(height: 32),
            _buildSectionLabel("THEME COLOR"),
            const SizedBox(height: 16),
            _buildColorPicker(),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  PremiumSnackbar.show(context, message: "Promotion Created Successfully!");
                },
                child: const Text("CREATE PROMOTION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
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
      label,
      style: TextStyle(
        color: colorExt.primary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTicketPreview() {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
               right: -40, top: -40,
               child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withValues(alpha: 0.1)),
            ),
            Positioned(
               left: -20, bottom: -20,
               child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                           child: Text("TASTY BITES", style: TextStyle(color: _selectedColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                         ),
                         const SizedBox(height: 12),
                         Text(
                           _discountController.text.isEmpty ? "50% OFF" : _discountController.text,
                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, height: 1),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           _descController.text.isEmpty ? "Special discount on all items" : _descController.text,
                           style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                         ),
                      ],
                    ),
                  ),
                  const VerticalDivider(color: Colors.white24, width: 40, indent: 10, endIndent: 10, thickness: 2),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text("OFFER", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 14)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ).animate(target: 1).scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorExt.placeholder, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: colorExt.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _colors.map((color) {
        bool isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: 200.ms,
            width: isSelected ? 52 : 44,
            height: isSelected ? 52 : 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: colorExt.surface, width: 4) : null,
              boxShadow: isSelected ? [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))
              ] : null
            ),
            child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 24) : null,
          ),
        );
      }).toList(),
    );
  }
}
