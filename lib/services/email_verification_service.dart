import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth email verification (same [ActionCodeSettings] everywhere).
class EmailVerificationService {
  EmailVerificationService._();

  static const String continueUrl =
      'https://speakdine-8f4e9.web.app/email_verified.html';

  static Future<void> sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: continueUrl,
          handleCodeInApp: false,
          androidPackageName: 'com.example.speak_dine',
          androidMinimumVersion: '1',
        ),
      );
    } catch (_) {
      await user.sendEmailVerification();
    }
  }
}
