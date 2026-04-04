import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:speak_dine/services/email_verification_service.dart';
import 'package:speak_dine/utils/toast_helper.dart';

/// Shown after email/password (or Google) sign-in when [User.emailVerified] is false.
/// User stays signed in until this dialog is closed; caller should [signOut] afterward.
Future<void> showUnverifiedEmailDialog(BuildContext parentContext) {
  return showDialog<void>(
    context: parentContext,
    barrierDismissible: false,
    builder: (ctx) {
      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      return material.AlertDialog(
        title: const material.Text('Verify your email'),
        content: _UnverifiedEmailDialogBody(
          parentContext: parentContext,
          email: email,
        ),
        actions: [
          material.TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const material.Text('Close'),
          ),
        ],
      );
    },
  );
}

class _UnverifiedEmailDialogBody extends StatefulWidget {
  const _UnverifiedEmailDialogBody({
    required this.parentContext,
    required this.email,
  });

  final BuildContext parentContext;
  final String email;

  @override
  State<_UnverifiedEmailDialogBody> createState() =>
      _UnverifiedEmailDialogBodyState();
}

class _UnverifiedEmailDialogBodyState extends State<_UnverifiedEmailDialogBody> {
  bool _sending = false;
  int _cooldownSec = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSec = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownSec--;
        if (_cooldownSec <= 0) _cooldownTimer?.cancel();
      });
    });
  }

  Future<void> _resend() async {
    if (_cooldownSec > 0 || _sending) return;
    final user = FirebaseAuth.instance.currentUser;
    final parent = widget.parentContext;
    if (user == null) {
      if (parent.mounted) {
        showAppToast(parent, 'Session expired. Try signing in again.');
      }
      return;
    }
    setState(() => _sending = true);
    try {
      await EmailVerificationService.sendVerificationEmail(user);
      if (!mounted) return;
      if (parent.mounted) {
        showAppToast(
          parent,
          'Verification email sent. Check inbox and spam folder.',
        );
      }
      _startCooldown();
    } on FirebaseAuthException catch (e) {
      var msg = 'Could not resend the email. Try again in a few minutes.';
      if (e.code == 'too-many-requests') {
        msg = 'Too many requests. Wait a few minutes, then try again.';
      }
      if (!mounted) return;
      if (parent.mounted) showAppToast(parent, msg);
    } catch (_) {
      if (!mounted) return;
      if (parent.mounted) {
        showAppToast(parent, 'Could not resend. Try again later.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emailLine = widget.email.isNotEmpty
        ? 'We use ${widget.email}.'
        : 'Use the same address you registered with.';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'You need to verify your email before you can use Speak Dine. '
          '$emailLine',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        _sending
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : PrimaryButton(
                onPressed: _cooldownSec > 0 ? null : _resend,
                child: Text(
                  _cooldownSec > 0
                      ? 'Resend email in ${_cooldownSec}s'
                      : 'Resend verification email',
                ),
              ),
      ],
    );
  }
}
