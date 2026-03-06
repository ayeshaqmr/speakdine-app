import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/widgets/password_strength_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;
  
  const ForgotPasswordScreen({
    super.key,
    required this.userType,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordViewState();
}

enum RecoveryMethod { email, phone }

class _ForgotPasswordViewState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // New controller for phone
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showOTPField = false;
  bool _showPasswordResetField = false;
  String? _errorMessage;
  String? _actionCode;
  
  RecoveryMethod _selectedMethod = RecoveryMethod.email;
  bool _emailHasText = false;
  bool _phoneHasText = false;
  bool _otpHasText = false;
  bool _newPasswordHasText = false;
  bool _confirmPasswordHasText = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );
    _animController.forward();

    _emailController.addListener(() => setState(() => _emailHasText = _emailController.text.isNotEmpty));
    _phoneController.addListener(() => setState(() => _phoneHasText = _phoneController.text.isNotEmpty));
    _otpController.addListener(() => setState(() => _otpHasText = _otpController.text.isNotEmpty));
    _newPasswordController.addListener(() => setState(() => _newPasswordHasText = _newPasswordController.text.isNotEmpty));
    _confirmPasswordController.addListener(() => setState(() => _confirmPasswordHasText = _confirmPasswordController.text.isNotEmpty));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;
    if (_selectedMethod == RecoveryMethod.email) {
       error = await _authService.sendPasswordResetOTP(
        _emailController.text.trim(),
        widget.userType,
      );
    } else {
      // Phone OTP send for forgot password 
      // Integrate with phone verification service here
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      setState(() => _showOTPField = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedMethod == RecoveryMethod.email 
            ? 'Password reset email sent!' 
            : 'OTP sent to your mobile number!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code');
      return;
    }

    // For Phone Sync
    if (_selectedMethod == RecoveryMethod.phone) {
       setState(() => _isLoading = true);
       final error = await _authService.verifyPhoneOTP(_otpController.text);
       setState(() => _isLoading = false);
       if (error != null) {
         setState(() => _errorMessage = error);
         return;
       }
       // If success
       setState(() {
        _showPasswordResetField = true;
        _errorMessage = null;
       });
       return;
    }

    // For Email Link (Manual Code Paste)
    try {
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized.');
      }

      final actionCode = _otpController.text.trim();
      final auth = FirebaseAuth.instance;
      
      await auth.verifyPasswordResetCode(actionCode);
      
      setState(() {
        _showPasswordResetField = true;
        _actionCode = actionCode;
        _errorMessage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code verified! Please enter your new password.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Invalid verification code');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _handleResetPassword() async {
    setState(() => _errorMessage = null);

    if (_newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter and confirm your new password');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
      return;
    }
    final strengthError = validatePasswordStrength(_newPasswordController.text);
    if (strengthError != null) {
      setState(() => _errorMessage = strengthError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = FirebaseAuth.instance;

      if (_actionCode != null) {
        await auth.confirmPasswordReset(
          code: _actionCode!,
          newPassword: _newPasswordController.text,
        );
      } else {
        // Handle Phone Reset flow
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          /// 🌤 Background
          Image.asset(
            "assets/bg_light.png",
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              ),
            ),
          ),

          /// 🔙 Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorExt.primary),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black12,
                  elevation: 5,
                  padding: const EdgeInsets.all(12),
                ),
              ),
          ).animate().fadeIn(duration: 400.ms),

          /// 🟡 Header (MATCHES SIGN IN)
          Positioned(
            top: size.height * 0.10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorExt.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.userType == 'customer' 
                        ? Icons.person_rounded 
                        : Icons.restaurant_rounded,
                      size: 50,
                      color: colorExt.primary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                const SizedBox(height: 16),

                Text(
                  "Forgot Password?",
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: colorExt.primaryText,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                Text(
                  "Recover access to your ${widget.userType} account",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: colorExt.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),
              ],
            ),
          ),

          /// 🧊 Glass Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnim,
              child: _glassCard(),
            ),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// GLASS CARD
  /// =======================
  Widget _glassCard() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (MediaQuery.of(context).viewInsets.bottom > 0 ? 0.9 : 0.65),
          ),
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorExt.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorExt.error.withValues(alpha: 0.5))
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: colorExt.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.outfit(color: colorExt.error, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    if (_showPasswordResetField) ...[
                       _buildResetFields(),
                    ] else if (_showOTPField) ...[
                      _buildOTPFields(),
                    ] else ...[
                      _buildMethodSelector(),
                      const SizedBox(height: 20),
                      _buildInputPhase(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorExt.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RecoveryMethod>(
          value: _selectedMethod,
          icon: Icon(Icons.expand_more_rounded, color: colorExt.primary),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(24),
          items: [
            _buildDropdownItem(
              title: "Recover via Email",
              subtitle: "Receive a password reset link",
              icon: Icons.email_rounded,
              value: RecoveryMethod.email,
              semanticsLabel: "Recover password via email link",
            ),
            _buildDropdownItem(
              title: "Recover via SMS / Phone",
              subtitle: "Get a reset OTP on your mobile",
              icon: Icons.phone_android_rounded,
              value: RecoveryMethod.phone,
              semanticsLabel: "Recover password via mobile SMS or WhatsApp OTP",
            ),
          ],
          onChanged: (RecoveryMethod? newValue) {
            if (newValue != null) {
              setState(() => _selectedMethod = newValue);
            }
          },
        ),
      ),
    );
  }

  DropdownMenuItem<RecoveryMethod> _buildDropdownItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required RecoveryMethod value,
    required String semanticsLabel,
  }) {
    return DropdownMenuItem<RecoveryMethod>(
      value: value,
      child: Semantics(
        label: semanticsLabel,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorExt.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorExt.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorExt.primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorExt.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPhase() {
    if (_selectedMethod == RecoveryMethod.email) {
       return Column(
        children: [
          Text(
            "Enter your registered email associated with your ${widget.userType} account.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: colorExt.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 30),
          _inputField(
            controller: _emailController,
            label: widget.userType == 'customer' 
                  ? "Username or Email" 
                  : "Restaurant Email",
            icon: widget.userType == 'customer' 
                  ? Icons.person_rounded 
                  : Icons.restaurant_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email or username';
              }
              return null;
            },
            hasText: _emailHasText,
          ),
          const SizedBox(height: 40),
          _primaryButton(
            text: "SEND RESET LINK",
            onPressed: _isLoading ? null : _handleSendOTP,
          ),
        ],
      );
    } else {
      return Column(
        children: [
           Text(
            "Enter your registered mobile number for ${widget.userType} account.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorExt.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 30),
            _inputField(
            controller: _phoneController,
            label: widget.userType == 'customer' 
                  ? "Mobile Number" 
                  : "Restaurant Phone",
            icon: Icons.phone_android_rounded,
             validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
            hasText: _phoneHasText,
           ),
           const SizedBox(height: 40),
           _primaryButton(
            text: "SEND OTP",
            onPressed: _isLoading ? null : _handleSendOTP,
          ),
        ],
      );
    }
  }

  Widget _buildOTPFields() {
    return Column(
      children: [
        Text(
          _selectedMethod == RecoveryMethod.email 
             ? "Check your email! We sent a reset link with an 'oobCode'. Paste it below."
             : "Enter the OTP sent to your mobile via SMS / WhatsApp.",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: colorExt.secondaryText, fontSize: 14),
        ),
        const SizedBox(height: 30),
        _inputField(
          controller: _otpController,
          label: _selectedMethod == RecoveryMethod.email ? "Action Code" : "OTP Code",
          icon: _selectedMethod == RecoveryMethod.email ? Icons.vpn_key_rounded : Icons.sms_rounded,
          hint: _selectedMethod == RecoveryMethod.email ? "Paste oobCode here" : "123456",
          hasText: _otpHasText,
        ),
        const SizedBox(height: 40),
        _primaryButton(
          text: "VERIFY CODE",
          onPressed: _isLoading ? null : _handleVerifyOTP,
        ),
        TextButton(
          onPressed: () => setState(() => _showOTPField = false),
          child: Text("Back", style: GoogleFonts.outfit(color: colorExt.secondaryText, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildResetFields() {
    return Column(
      children: [
         Text(
          "Create a new strong password for your account.",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: colorExt.secondaryText, fontSize: 14),
        ),
        const SizedBox(height: 30),
        _inputField(
          controller: _newPasswordController,
          label: "New Password",
          icon: Icons.password_rounded,
          obscureText: _obscureNewPassword,
          suffix: IconButton(
            icon: Icon(_obscureNewPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
          ),
          hasText: _newPasswordHasText,
        ),
        const SizedBox(height: 4),
        PasswordStrengthIndicator(controller: _newPasswordController),
        const SizedBox(height: 18),
        _inputField(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          icon: Icons.password_rounded,
          obscureText: _obscureConfirmPassword,
          suffix: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          hasText: _confirmPasswordHasText,
        ),
        const SizedBox(height: 40),
        _primaryButton(
          text: "RESET PASSWORD",
          onPressed: _isLoading ? null : _handleResetPassword,
        ),
      ],
    );
  }

  /// =======================
  /// COMMON WIDGETS
  /// =======================
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
    bool hasText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorExt.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: hasText ? colorExt.primary : colorExt.primaryText,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.outfit(
            color: colorExt.secondaryText,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorExt.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colorExt.primary,
                size: 20,
              ),
            ),
          ),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: colorExt.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: colorExt.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: colorExt.error,
              width: 1.5,
            ),
          ),
          errorStyle: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorExt.error,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({required String text, VoidCallback? onPressed}) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorExt.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
          shadowColor: colorExt.primary.withValues(alpha: 0.3),
        ),
        child: _isLoading 
          ? const SizedBox(
              height: 24, 
              width: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
      ),
    );
  }
}
