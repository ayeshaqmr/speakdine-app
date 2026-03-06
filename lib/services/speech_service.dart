import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Singleton wrapper around STT/TTS with English + Urdu support.
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  static const String localeEnglish = 'en-US';
  static const String localeUrdu = 'ur-PK';

  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttReady = false;

  bool get isListening => _stt.isListening;
  bool get isSttReady => _sttReady;

  Future<bool> init() async {
    if (_sttReady) return true;
    
    // TTS defaults
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Initialize STT
    _sttReady = await _stt.initialize(
      onError: (e) => debugPrint('[SpeechService][STT] $e'),
      onStatus: (s) => debugPrint('[SpeechService][STT] status=$s'),
    );

    return _sttReady;
  }

  /// TEXT TO SPEECH
  Future<void> speak(
    String text, {
    String? language,
    bool interrupt = true,
  }) async {
    if (text.trim().isEmpty) return;

    if (interrupt) {
      await _tts.stop();
    }

    if (language != null) {
      await _tts.setLanguage(language);
    } else {
      await _tts.setLanguage(localeEnglish);
    }

    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// SPEECH TO TEXT
  Future<bool> startListening({
    required ValueChanged<String> onResultText,
    String? locale,
    Duration listenFor = const Duration(seconds: 8),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_sttReady) {
      final ok = await init();
      if (!ok) return false;
    }

    if (_stt.isListening) return true;

    await _stt.listen(
      localeId: locale ?? localeEnglish,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (result) {
        onResultText(result.recognizedWords);
      },
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation
    );

    return true; 
  }

  Future<void> stopListening() async {
    await _stt.stop();
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
  }

  Future<void> dispose() async {
    await _tts.stop();
    await _stt.cancel();
  }
}