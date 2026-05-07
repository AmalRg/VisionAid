import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';
import '../services/ocr_service.dart';
import '../services/language_service.dart';
import '../services/tts_service.dart';
import '../services/notification_service.dart';
import '../models/history_item.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});
  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  CameraController? _cam;
  bool _camReady  = false;
  bool _scanning  = false;
  bool _reading   = false;

  String _text       = '';
  String _translated = '';
  String _detLang    = '';
  bool   _hasResult  = false;

  late SettingsProvider _settings;
  late HistoryProvider  _history;
  late TtsService       _tts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settings = context.read<SettingsProvider>();
      _history  = context.read<HistoryProvider>();
      _tts      = context.read<TtsService>();
      _initCam();
    });
  }

  Future<void> _initCam() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) return;
      final back = cams.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      _cam = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await _cam!.initialize();
      if (mounted) setState(() => _camReady = true);
    } catch (e) { debugPrint('Cam: $e'); }
  }

  Future<void> _scan() async {
    if (_cam == null || !_camReady || _scanning) return;
    setState(() { _scanning = true; _hasResult = false; _text = ''; _translated = ''; _detLang = ''; });

    try {
      final xFile   = await _cam!.takePicture();
      final input   = InputImage.fromFilePath(xFile.path);
      final rawText = await OcrService.instance.recognizeText(input);

      if (!mounted) return;
      if (rawText.trim().isEmpty) {
        setState(() => _scanning = false);
        _snack('⚠ Aucun texte détecté — rapprochez-vous et éclairez bien', AppColors.warning);
        return;
      }

      // detection langue
      String lang = 'fr';
      try {
        final d = await LanguageService.instance.detectLanguage(rawText.trim());
        if (d != 'und' && d.isNotEmpty) lang = d;
      } catch (_) {}

      // traduire vers la langue de l'interface
      String translated = '';
      final ifaceLang = _settings.interfaceLanguage;
      if (_settings.autoTranslate && lang != ifaceLang) {
        try {
          translated = await LanguageService.instance.translate(rawText.trim(), lang, ifaceLang);
        } catch (e) { debugPrint('Trad: $e'); }
      }

      if (!mounted) return;
      setState(() {
        _text       = rawText.trim();
        _detLang    = lang;
        _translated = translated;
        _hasResult  = true;
        _scanning   = false;
      });

      // historique
      await _history.addItem(HistoryItem(
        type: ScanType.ocr,
        title: _firstLine(rawText),
        content: rawText.trim(),
        translatedContent: translated.isNotEmpty ? translated : null,
        detectedLanguage: lang,
        targetLanguage: translated.isNotEmpty ? ifaceLang : null,
        timestamp: DateTime.now(),
        imagePath: xFile.path,
      ));

      if (_settings.notificationsEnabled) {
        NotificationService.instance.showScanSaved(_firstLine(rawText));
      }

      // lecture immediate
      await _speak();

    } catch (e) {
      debugPrint('Scan: $e');
      if (mounted) {
        setState(() => _scanning = false);
        _snack('Erreur: $e', AppColors.danger);
      }
    }
  }

  Future<void> _speak() async {
    if (_text.isEmpty) return;
    setState(() => _reading = true);

    try {
      String textToRead;
      String langToUse;

      if (_translated.isNotEmpty) {
        textToRead = _translated;
        langToUse  = _settings.interfaceLanguage;
      } else {
        textToRead = _text;
        langToUse  = _detLang.isNotEmpty ? _detLang : _settings.interfaceLanguage;
      }

      debugPrint('TTS: langue=$langToUse, longueur=${textToRead.length}');
      await _tts.setLanguage(langToUse);
      await _tts.speak(textToRead, language: langToUse, speed: 0.45);

    } catch (e) {
      debugPrint('TTS error: $e');
    }
    if (mounted) setState(() => _reading = false);
  }

  void _stopSpeak() { _tts.stop(); setState(() => _reading = false); }

  Future<void> _translate() async {
    if (_text.isEmpty) return;
    setState(() => _scanning = true);
    try {
      final t = await LanguageService.instance.translate(
          _text, _detLang, _settings.targetLanguage);
      if (mounted) setState(() { _translated = t; _scanning = false; });
    } catch (_) {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _translated.isNotEmpty ? _translated : _text));
    _snack('✓ Texte copié', AppColors.primary);
  }

  void _reset() {
    _tts.stop();
    setState(() { _hasResult=false; _text=''; _translated=''; _detLang=''; _reading=false; });
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 3)));
  }

  String _firstLine(String t) {
    final f = t.trim().split('\n').first.trim();
    return f.length > 40 ? '${f.substring(0, 40)}…' : f;
  }

  @override
  void dispose() { _tts.stop(); _cam?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(child: Column(children: [

        // AppBar
        _AppBar(onBack: () => context.pop()),

        // Viewfinder
        Expanded(
          flex: _hasResult ? 4 : 7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _camReady && _cam != null
                    ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width:  _cam!.value.previewSize!.height,
                      height: _cam!.value.previewSize!.width,
                      child: CameraPreview(_cam!),
                    ),
                  ),
                )
                    : Container(
                  color: AppColors.card(context),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              ),

              if (_hasResult)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(color: Colors.black45),
                ),

              // Cadre
              Positioned.fill(child: Padding(
                padding: const EdgeInsets.all(20),
                child: CustomPaint(painter: _Frame()),
              )),

              // Ligne scan
              if (_scanning)
                Positioned.fill(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _ScanLine(),
                )),

              // Guide
              if (!_scanning && !_hasResult)
                Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
                  child: const Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.center_focus_strong, color: AppColors.primary, size: 40),
                    SizedBox(height: 10),
                    Text('Pointez vers un texte\npuis appuyez sur Scanner',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                  ]),
                )),

              // Badge succes
              if (_hasResult && !_scanning)
                Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, color: Colors.black, size: 18),
                    SizedBox(width: 6),
                    Text('Texte extrait !', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  ]),
                )),

              // Bouton scanner
              Positioned(bottom: 14, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (_hasResult) ...[
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: Colors.black54,
                            borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white30)),
                        child: const Text('↺ Nouveau', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  GestureDetector(
                    onTap: _scanning ? null : _scan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: _scanning ? Colors.grey : AppColors.primary,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4))],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_scanning ? Icons.hourglass_top : Icons.document_scanner, color: Colors.black, size: 20),
                        const SizedBox(width: 8),
                        Text(_scanning ? 'Analyse...' : '  Scanner  ',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),

        // resultat
        if (_hasResult || _scanning)
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TEXTE EXTRAIT',
                    style: TextStyle(color: AppColors.hint(context), fontSize: 10,
                        letterSpacing: 1.4, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                if (_scanning)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 8),
                      Text('Reconnaissance en cours...'),
                    ]),
                  ))
                else ...[
                  // Badges
                  if (_detLang.isNotEmpty)
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      _Badge(text: '${_detLang.toUpperCase()} détecté', color: AppColors.info),
                      if (_translated.isNotEmpty)
                        _Badge(
                          text: '→ ${_settings.interfaceLanguage.toUpperCase()}',
                          color: AppColors.warning,
                        ),
                    ]),
                  const SizedBox(height: 8),

                  // Texte
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brd(context)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _translated.isNotEmpty ? _translated : _text,
                        style: TextStyle(color: AppColors.txt(context), fontSize: 14, height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(children: [
                    Expanded(child: _ActionBtn(
                      icon: _reading ? Icons.stop_circle : Icons.volume_up,
                      label: _reading ? 'Stop' : 'Lire',
                      color: AppColors.primary, filled: true,
                      onTap: _reading ? _stopSpeak : _speak,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn(icon: Icons.translate, label: 'Traduire', onTap: _translate)),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn(icon: Icons.copy, label: 'Copier', onTap: _copy)),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn(icon: Icons.refresh, label: 'Nouveau', onTap: _reset)),
                  ]),
                ],
                const SizedBox(height: 8),
              ]),
            ),
          ),

        if (!_hasResult && !_scanning) const SizedBox(height: 8),
      ])),
    );
  }
}

// Widgets

class _AppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _AppBar({required this.onBack});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Icon(Icons.arrow_back, color: AppColors.txt(context), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text('Scanner OCR',
            style: TextStyle(color: AppColors.txt(context), fontSize: 18, fontWeight: FontWeight.w600)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Text('Hors ligne', style: TextStyle(color: AppColors.primary, fontSize: 11)),
        ),
      ]),
    );
  }
}

class _Frame extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 3..style = PaintingStyle.stroke;
    const c = 28.0;
    canvas.drawPath(Path()..moveTo(0, c)..lineTo(0, 0)..lineTo(c, 0), p);
    canvas.drawPath(Path()..moveTo(size.width-c, 0)..lineTo(size.width, 0)..lineTo(size.width, c), p);
    canvas.drawPath(Path()..moveTo(0, size.height-c)..lineTo(0, size.height)..lineTo(c, size.height), p);
    canvas.drawPath(Path()..moveTo(size.width-c, size.height)..lineTo(size.width, size.height)..lineTo(size.width, size.height-c), p);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}
class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _p;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _p = Tween<double>(begin: 0.05, end: 0.95).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => CustomPaint(painter: _Line(pos: _p.value)),
  );
}
class _Line extends CustomPainter {
  final double pos;
  const _Line({required this.pos});
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * pos;
    canvas.drawLine(Offset(0, y), Offset(size.width, y),
        Paint()..color = AppColors.primary.withOpacity(0.9)..strokeWidth = 2);
    canvas.drawLine(Offset(0, y), Offset(size.width, y),
        Paint()..color = AppColors.primary.withOpacity(0.25)..strokeWidth = 8);
  }
  @override
  bool shouldRepaint(covariant _Line o) => o.pos != pos;
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback? onTap; final Color color; final bool filled;
  const _ActionBtn({required this.icon, required this.label, this.onTap,
    this.color = AppColors.textSecondary, this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.15) : AppColors.card(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: filled ? color.withOpacity(0.5) : AppColors.brd(context)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: filled ? color : AppColors.sub(context), size: 20),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: filled ? color : AppColors.sub(context), fontSize: 10)),
      ]),
    ),
  );
}
