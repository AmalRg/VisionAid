import 'package:flutter/material.dart'; // ← pour Size
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class MlKitService {
  static final MlKitService instance = MlKitService._();
  MlKitService._();

  ImageLabeler? _labeler;
  ObjectDetector? _detector;

  void init() {
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.60),
    );
    _detector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
  }

  // Étiquetage d'image
  Future<List<ImageLabel>> labelImage(InputImage image) async {
    _labeler ??= ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.60),
    );
    return await _labeler!.processImage(image);
  }

  // Détection d'objets avec bounding boxes
  Future<List<DetectedObject>> detectObjects(InputImage image) async {
    _detector ??= ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
    return await _detector!.processImage(image);
  }

  // Logique d'alerte obstacle
  int checkObstacleLevel(
      List<DetectedObject> objects,
      Size imageSize,
      double threshold,
      ) {
    if (objects.isEmpty) return 0;

    final imageArea = imageSize.width * imageSize.height;
    double maxRatio = 0;

    for (final obj in objects) {
      final box = obj.boundingBox;
      final objArea = box.width * box.height;
      final ratio = objArea / imageArea;
      if (ratio > maxRatio) maxRatio = ratio;
    }

    if (maxRatio >= threshold * 1.5) return 2;
    if (maxRatio >= threshold) return 1;
    return 0;
  }

  // Description vocale
  String buildDescription(List<ImageLabel> labels, String language) {
    if (labels.isEmpty) return _emptyMsg(language);
    final names = labels.take(4).map((l) => l.label.toLowerCase()).join(', ');
    switch (language) {
      case 'fr': return 'Devant vous : $names';
      case 'en': return 'In front of you: $names';
      case 'ar': return 'أمامك: $names';
      default:   return 'Devant vous : $names';
    }
  }

  String buildObstacleAlert(int level, String language) {
    switch (language) {
      case 'fr':
        return level == 2
            ? 'Attention ! Obstacle très proche !'
            : 'Obstacle détecté à distance moyenne.';
      case 'en':
        return level == 2
            ? 'Warning! Very close obstacle!'
            : 'Obstacle detected at medium distance.';
      case 'ar':
        return level == 2
            ? 'تحذير! عائق قريب جدًا!'
            : 'تم اكتشاف عائق على مسافة متوسطة.';
      default:
        return 'Obstacle détecté !';
    }
  }

  String _emptyMsg(String language) {
    switch (language) {
      case 'fr': return 'Aucun objet détecté.';
      case 'en': return 'No objects detected.';
      case 'ar': return 'لم يتم اكتشاف أي كائن.';
      default:   return 'Aucun objet détecté.';
    }
  }

  void dispose() {
    _labeler?.close();
    _detector?.close();
  }
}