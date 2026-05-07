import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';
import '../services/mlkit_service.dart';
import '../services/tts_service.dart';
import '../models/history_item.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});
  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  CameraController? _cam;
  bool _camReady    = false;
  bool _processing  = false;
  bool _voiceOn     = true;
  bool _vibOn       = true;

  List<ImageLabel>          _labels  = [];
  List<DetectedObject> _objects = [];
  int    _obstacleLevel  = 0;
  String _displayDesc    = 'En attente d\'analyse...';
  String _lastSpoken     = '';
  Size?  _previewSize;
  DateTime _lastSpokenAt = DateTime.now().subtract(const Duration(seconds: 10));

  late TtsService       _tts;
  late SettingsProvider _settings;
  late HistoryProvider  _history;

  @override
  void initState() {
    super.initState();
    MlKitService.instance.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settings = context.read<SettingsProvider>();
      _tts      = context.read<TtsService>();
      _history  = context.read<HistoryProvider>();
      _voiceOn  = _settings.ttsEnabled;
      _vibOn    = _settings.vibrationEnabled;
      _initCam();
    });
  }

  Future<void> _initCam() async {
    final cams = await availableCameras();
    if (cams.isEmpty) return;
    final back = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );
    _cam = CameraController(
      back, ResolutionPreset.medium, enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _cam!.initialize();
    if (!mounted) return;
    setState(() { _camReady = true; _previewSize = _cam!.value.previewSize; });
    _cam!.startImageStream(_onFrame);
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_processing) return;
    _processing = true;
    try {
      final inputImg = _toInputImage(image);
      if (inputImg == null) { _processing = false; return; }

      final labels  = await MlKitService.instance.labelImage(inputImg);
      final objects = await MlKitService.instance.detectObjects(inputImg);

      final filtered = labels
          .where((l) => l.confidence >= _settings.confidenceThreshold)
          .toList();

      final imgSz    = Size(image.width.toDouble(), image.height.toDouble());
      final obsLevel = MlKitService.instance.checkObstacleLevel(
          objects, imgSz, _settings.obstacleThreshold);

      if (!mounted) { _processing = false; return; }
      setState(() {
        _labels        = filtered;
        _objects       = objects;
        _obstacleLevel = obsLevel;
      });

      final now     = DateTime.now();
      final elapsed = now.difference(_lastSpokenAt).inSeconds;

      if (obsLevel > 0) {
        final msg = MlKitService.instance.buildObstacleAlert(obsLevel, _settings.interfaceLanguage);
        setState(() => _displayDesc = msg);
        if (_vibOn) {
          final hasVib = await Vibration.hasVibrator() ?? false;
          if (hasVib) {
            obsLevel == 2
                ? Vibration.vibrate(pattern: [0, 300, 100, 300])
                : Vibration.vibrate(duration: 200);
          }
        }
        if (_voiceOn && elapsed >= 3) {
          _lastSpokenAt = now;
          _tts.speak(msg, language: _settings.interfaceLanguage);
        }
      } else if (filtered.isNotEmpty) {
        final desc = MlKitService.instance.buildDescription(filtered, _settings.interfaceLanguage);
        setState(() => _displayDesc = desc);
        if (_voiceOn && elapsed >= 4 && desc != _lastSpoken) {
          _lastSpoken   = desc;
          _lastSpokenAt = now;
          _tts.speak(desc, language: _settings.interfaceLanguage);
        }
      } else {
        setState(() => _displayDesc = 'Analyse en cours...');
      }
    } catch (e) { debugPrint('Frame: $e'); }
    _processing = false;
  }

  InputImage? _toInputImage(CameraImage image) {
    try {
      final rotation = InputImageRotationValue.fromRawValue(
          _cam!.description.sensorOrientation) ??
          InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null || image.planes.isEmpty) return null;
      final plane = image.planes[0];
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (_) { return null; }
  }

  Future<void> _takePhoto() async {
    if (_cam == null || !_camReady) return;
    await _cam!.stopImageStream();
    try {
      final xFile    = await _cam!.takePicture();
      final inputImg = InputImage.fromFilePath(xFile.path);
      final labels   = await MlKitService.instance.labelImage(inputImg);
      if (labels.isNotEmpty) {
        final desc = MlKitService.instance.buildDescription(labels, _settings.interfaceLanguage);
        await _history.addItem(HistoryItem(
          type: ScanType.detection, title: 'Scène détectée',
          content: labels.map((l) => l.label).join(', '),
          timestamp: DateTime.now(), imagePath: xFile.path,
          objectCount: labels.length, confidence: labels.first.confidence,
        ));
        setState(() => _displayDesc = desc);
        if (_voiceOn) _tts.speak(desc, language: _settings.interfaceLanguage);
      }
    } catch (e) { debugPrint('Photo: $e'); }
    if (mounted) _cam!.startImageStream(_onFrame);
  }

  @override
  void dispose() {
    _cam?.stopImageStream();
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          if (_camReady && _cam != null)
            Positioned.fill(child: CameraPreview(_cam!)),

          if (!_camReady)
            Positioned.fill(
              child: Container(
                color: AppColors.bg(context),
                child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),

          // Bounding boxes
          if (_camReady && _previewSize != null && _objects.isNotEmpty)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) => CustomPaint(
                  painter: _BoxPainter(
                    objects: _objects, labels: _labels,
                    imageSize: _previewSize!,
                    screenSize: Size(constraints.maxWidth, constraints.maxHeight),
                    threshold: _settings.obstacleThreshold,
                  ),
                ),
              ),
            ),

          // AppBar
          Positioned(top: 0, left: 0, right: 0,
              child: _DetAppBar(obsLevel: _obstacleLevel, onBack: () => context.pop())),

          // Bouton declencheur
          Positioned(bottom: 160, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16)],
                  ),
                  child: const Icon(Icons.camera, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          // 3 Boxes en bas
          Positioned(bottom: 0, left: 0, right: 0,
            child: _BottomPanel(
              description: _displayDesc,
              voiceOn: _voiceOn, vibOn: _vibOn,
              onVoice: () => setState(() => _voiceOn = !_voiceOn),
              onVib:   () => setState(() => _vibOn   = !_vibOn),
              onPhoto: _takePhoto,
            ),
          ),
        ]),
      ),
    );
  }
}

// Widgets

class _DetAppBar extends StatelessWidget {
  final int obsLevel;
  final VoidCallback onBack;
  const _DetAppBar({required this.obsLevel, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24)),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Text('Détection en direct',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: obsLevel > 0
                ? (obsLevel == 2 ? AppColors.danger : AppColors.warning)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            obsLevel == 2 ? '⚠ OBSTACLE!' : obsLevel == 1 ? '⚠ Obstacle' : 'ML Kit actif',
            style: TextStyle(
              color: obsLevel > 0 ? Colors.white : Colors.black,
              fontSize: 11, fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final String description;
  final bool voiceOn, vibOn;
  final VoidCallback onVoice, onVib, onPhoto;
  const _BottomPanel({required this.description, required this.voiceOn,
    required this.vibOn, required this.onVoice, required this.onVib, required this.onPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.95), Colors.transparent],
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(width: 10, height: 10,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text('"$description"',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
        ),
        const SizedBox(height: 100),
        Row(children: [
          _Btn(label: voiceOn ? 'Voix ON' : 'Voix OFF', active: voiceOn, onTap: onVoice),
          const SizedBox(width: 8),
          _Btn(label: vibOn ? 'Vibration' : 'Vibr. OFF', active: vibOn, onTap: onVib),
          const SizedBox(width: 8),
          _Btn(label: 'Photo', active: false, onTap: onPhoto),
        ]),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.2) : Colors.black38,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : Colors.white24),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(
                color: active ? AppColors.primary : Colors.white,
                fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    ));
  }
}

class _BoxPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final List<ImageLabel> labels;
  final Size imageSize, screenSize;
  final double threshold;
  const _BoxPainter({required this.objects, required this.labels,
    required this.imageSize, required this.screenSize, required this.threshold});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width  / imageSize.height;
    final scaleY = size.height / imageSize.width;

    for (int i = 0; i < objects.length; i++) {
      final obj = objects[i];
      final box = obj.boundingBox;
      final rect = Rect.fromLTRB(
          box.left * scaleX, box.top * scaleY, box.right * scaleX, box.bottom * scaleY);

      final ratio = (box.width * box.height) / (imageSize.width * imageSize.height);
      final isObs = ratio >= threshold;
      final color = isObs ? AppColors.danger : (i == 0 ? AppColors.primary : AppColors.warning);

      canvas.drawRect(rect, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5);
      canvas.drawRect(rect, Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.fill);

      final label = obj.labels.isNotEmpty
          ? '${obj.labels.first.text} ${(obj.labels.first.confidence * 100).toStringAsFixed(0)}%'
          : (isObs ? 'Obstacle!' : 'Objet');

      final tp = TextPainter(
        text: TextSpan(text: '  $label  ',
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                background: Paint()..color = color)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.left, (rect.top - 20).clamp(0, size.height)));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxPainter o) => true;
}
