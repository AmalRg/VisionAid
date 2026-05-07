import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  String _currentLang = 'fr-FR';

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(()  => _isPlaying = true);
    _tts.setCompletionHandler(() => _isPlaying = false);
    _tts.setCancelHandler(()   => _isPlaying = false);
    _tts.setErrorHandler((_)   => _isPlaying = false);
  }

  Future<void> speak(String text, {String? language, double? speed}) async {
    await stop();

    final langCode = _bcp(language ?? 'fr');
    if (langCode != _currentLang) {
      await _tts.setLanguage(langCode);
      _currentLang = langCode;
    }

    final rate = (speed != null) ? speed.clamp(0.1, 1.0) : 0.5;
    await _tts.setSpeechRate(rate);

    await _tts.speak(text);
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  Future<void> setLanguage(String langCode) async {
    final bcp = _bcp(langCode);
    await _tts.setLanguage(bcp);
    _currentLang = bcp;
  }

  Future<void> setSpeed(double speed) async {
    await _tts.setSpeechRate(speed.clamp(0.1, 1.0));
  }

  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0));
  }

  String _bcp(String code) {
    switch (code.toLowerCase().trim()) {
      case 'fr':    return 'fr-FR';
      case 'en':    return 'en-US';
      case 'ar':    return 'ar-SA';
      case 'fr-fr': return 'fr-FR';
      case 'en-us': return 'en-US';
      case 'ar-sa': return 'ar-SA';
      default:      return 'fr-FR';
    }
  }

  void dispose() => _tts.stop();
}
