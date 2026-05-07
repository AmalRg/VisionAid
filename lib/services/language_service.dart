import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageService {
  static final LanguageService instance = LanguageService._();
  LanguageService._();

  final LanguageIdentifier _identifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final Map<String, OnDeviceTranslator> _translators = {};

  Future<String> detectLanguage(String text) async {
    try {
      final lang = await _identifier.identifyLanguage(text);
      return lang;
    } catch (_) {
      return 'und';
    }
  }

  Future<String> translate(String text, String from, String to) async {
    try {
      final key = '${from}_$to';
      _translators[key] ??= OnDeviceTranslator(
        sourceLanguage: _toTranslateLanguage(from),
        targetLanguage: _toTranslateLanguage(to),
      );
      return await _translators[key]!.translateText(text);
    } catch (_) {
      return text;
    }
  }

  // telecharge le modele de traduction si nécessaire
  Future<bool> downloadModelIfNeeded(String langCode) async {
    try {
      final manager = OnDeviceTranslatorModelManager();
      final lang = _toTranslateLanguage(langCode).bcpCode;
      final downloaded = await manager.isModelDownloaded(lang);
      if (!downloaded) {
        await manager.downloadModel(lang);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  TranslateLanguage _toTranslateLanguage(String code) {
    switch (code) {
      case 'fr': return TranslateLanguage.french;
      case 'en': return TranslateLanguage.english;
      case 'ar': return TranslateLanguage.arabic;
      default:   return TranslateLanguage.french;
    }
  }

  String languageName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'Arabe';
      case 'und': return 'Indéfini';
      default:   return code.toUpperCase();
    }
  }

  void dispose() {
    _identifier.close();
    for (final t in _translators.values) t.close();
  }
}
