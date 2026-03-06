import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';
import 'package:speakdine_app/services/speech_service.dart';
import 'package:speakdine_app/services/llm_intent_service.dart';
import 'package:speakdine_app/widgets/premium_snackbar.dart';

class VoiceAssistantBubble extends StatefulWidget {
  final Function(String intent, String? query)? onCommand;
  const VoiceAssistantBubble({super.key, this.onCommand});

  @override
  State<VoiceAssistantBubble> createState() => _VoiceAssistantBubbleState();
}

class _VoiceAssistantBubbleState extends State<VoiceAssistantBubble> {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;

  void _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      bool ok = await _speechService.startListening(
        onResultText: (text) {
          if (!_speechService.isListening) {
             _processCommand(text);
          }
        },
      );
      if (ok) {
        setState(() => _isListening = true);
        _speechService.speak("How can I help you?", interrupt: true);
      }
    }
  }

  void _processCommand(String text) async {
    setState(() => _isListening = false);
    if (text.isEmpty) return;

    final response = await LLMIntentService.parseIntent(text);
    final String intent = response['intent'] ?? "UNKNOWN";
    final String msg = response['message'] ?? "I couldn't understand that.";
    final String? query = response['query'];

    _speechService.speak(msg);

    if (intent == "UNKNOWN") {
      if (mounted) PremiumSnackbar.show(context, message: "Unknown command: $text", isError: true);
    } else {
      if (widget.onCommand != null) {
        widget.onCommand!(intent, query);
      } else {
         // Default global actions if needed
         _handleGlobalIntent(intent, query);
      }
    }
  }

  void _handleGlobalIntent(String intent, String? query) {
    // This can be expanded or handled via callback in specific views
    debugPrint("Global Intent: $intent, Query: $query");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _isListening ? Colors.red : colorExt.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isListening ? Colors.red : colorExt.primary).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isListening)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)).fadeOut(),
            
            Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ).animate(target: _isListening ? 1 : 0)
       .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.2))
       .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
    );
  }
}
