import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool   _ttsEnabled           = true;
  double _ttsSpeed             = 0.5;
  double _ttsVolume            = 1.0;
  bool   _vibrationEnabled     = true;
  bool   _darkMode             = true;
  String _interfaceLanguage    = 'fr';
  bool   _autoTranslate        = true;
  String _targetLanguage       = 'ar';
  bool   _notificationsEnabled = false;
  double _confidenceThreshold  = 0.65;
  double _obstacleThreshold    = 0.30;

  bool   get ttsEnabled           => _ttsEnabled;
  double get ttsSpeed             => _ttsSpeed;
  double get ttsVolume            => _ttsVolume;
  bool   get vibrationEnabled     => _vibrationEnabled;
  bool   get darkMode             => _darkMode;
  String get interfaceLanguage    => _interfaceLanguage;
  bool   get autoTranslate        => _autoTranslate;
  String get targetLanguage       => _targetLanguage;
  bool   get notificationsEnabled => _notificationsEnabled;
  double get confidenceThreshold  => _confidenceThreshold;
  double get obstacleThreshold    => _obstacleThreshold;

  String get ttsSpeedLabel {
    if (_ttsSpeed <= 0.4)  return 'Lente';
    if (_ttsSpeed <= 0.65) return 'Normale';
    return 'Rapide';
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _ttsEnabled           = p.getBool('tts_enabled')            ?? true;
    _ttsSpeed             = p.getDouble('tts_speed')            ?? 0.5;
    _ttsVolume            = p.getDouble('tts_volume')           ?? 1.0;
    _vibrationEnabled     = p.getBool('vibration_enabled')      ?? true;
    _darkMode             = p.getBool('dark_mode')              ?? true;
    _interfaceLanguage    = p.getString('interface_language')   ?? 'fr';
    _autoTranslate        = p.getBool('auto_translate')         ?? true;
    _targetLanguage       = p.getString('target_language')      ?? 'ar';
    _notificationsEnabled = p.getBool('notifications_enabled')  ?? false;
    _confidenceThreshold  = p.getDouble('confidence_threshold') ?? 0.65;
    _obstacleThreshold    = p.getDouble('obstacle_threshold')   ?? 0.30;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('tts_enabled',            _ttsEnabled);
    await p.setDouble('tts_speed',            _ttsSpeed);
    await p.setDouble('tts_volume',           _ttsVolume);
    await p.setBool('vibration_enabled',      _vibrationEnabled);
    await p.setBool('dark_mode',              _darkMode);
    await p.setString('interface_language',   _interfaceLanguage);
    await p.setBool('auto_translate',         _autoTranslate);
    await p.setString('target_language',      _targetLanguage);
    await p.setBool('notifications_enabled',  _notificationsEnabled);
    await p.setDouble('confidence_threshold', _confidenceThreshold);
    await p.setDouble('obstacle_threshold',   _obstacleThreshold);
  }

  void setTtsEnabled(bool v)           { _ttsEnabled = v;            _save(); notifyListeners(); }
  void setTtsSpeed(double v)           { _ttsSpeed = v;              _save(); notifyListeners(); }
  void setTtsVolume(double v)          { _ttsVolume = v;             _save(); notifyListeners(); }
  void setVibrationEnabled(bool v)     { _vibrationEnabled = v;      _save(); notifyListeners(); }
  void setDarkMode(bool v)             { _darkMode = v;              _save(); notifyListeners(); }
  void setAutoTranslate(bool v)        { _autoTranslate = v;         _save(); notifyListeners(); }
  void setTargetLanguage(String v)     { _targetLanguage = v;        _save(); notifyListeners(); }
  void setNotificationsEnabled(bool v) { _notificationsEnabled = v;  _save(); notifyListeners(); }
  void setConfidenceThreshold(double v){ _confidenceThreshold = v;   _save(); notifyListeners(); }
  void setObstacleThreshold(double v)  { _obstacleThreshold = v;     _save(); notifyListeners(); }

  void setInterfaceLanguage(String v) {
    _interfaceLanguage = v;
    _save();
    notifyListeners();
  }

  Future<bool> isFirstLaunch() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('onboarding_done') ?? true;
  }

  Future<void> markOnboardingDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarding_done', false);
  }
}
