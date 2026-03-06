import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _cardNumber = "XXXX XXXX XXXX XXXX";
  String _cardHolder = "FULL NAME";
  String _expiry = "MM/YY";

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      setState(() {
        _cardNumber = _cardNumberController.text.isEmpty ? "XXXX XXXX XXXX XXXX" : _cardNumberController.text;
      });
    });
    _cardHolderController.addListener(() {
      setState(() {
        _cardHolder = _cardHolderController.text.isEmpty ? "FULL NAME" : _cardHolderController.text.toUpperCase();
      });
    });
    _expiryController.addListener(() {
      setState(() {
        _expiry = _expiryController.text.isEmpty ? "MM/YY" : _expiryController.text;
      });
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Add New Card",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis'
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildLiveCardPreview(),
            const SizedBox(height: 40),
            _buildInputFields(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCardPreview() {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.contactless_outlined, color: Colors.white70, size: 32),
              const Text("VISA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              fontFamily: 'Metropolis'
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CARD HOLDER", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(_cardHolder, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("EXPIRES", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(_expiry, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0).fadeIn(duration: 600.ms);
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _inputField(
          controller: _cardNumberController,
          label: "Card Number",
          icon: Icons.credit_card_rounded,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _inputField(
          controller: _cardHolderController,
          label: "Card Holder Name",
          icon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _inputField(
                controller: _expiryController,
                label: "Expiry Date",
                hint: "MM/YY",
                icon: Icons.calendar_month_outlined,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  ExpiryDateFormatter(),
                ],
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _inputField(
                controller: _cvvController,
                label: "CVV",
                hint: "***",
                icon: Icons.lock_outline_rounded,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      style: TextStyle(fontWeight: FontWeight.w700, color: colorExt.primaryText),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorExt.primary, size: 22),
        labelStyle: TextStyle(color: colorExt.placeholder, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: colorExt.textField.withValues(alpha: 0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: colorExt.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          // Placeholder for save action
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorExt.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          shadowColor: colorExt.primary.withValues(alpha: 0.3),
        ),
        child: const Text("SAVE CARD", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    
    String enteredData = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < enteredData.length; i++) {
      buffer.write(enteredData[i]);
      int index = i + 1;
      if (index % 4 == 0 && index != enteredData.length) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    
    String enteredData = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < enteredData.length; i++) {
      buffer.write(enteredData[i]);
      int index = i + 1;
      if (index == 2 && index != enteredData.length) {
        buffer.write('/');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}
