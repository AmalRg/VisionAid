enum ScanType { ocr, detection, obstacle }

class HistoryItem {
  final int? id;
  final ScanType type;
  final String title;
  final String content;
  final String? translatedContent;
  final String? detectedLanguage;
  final String? targetLanguage;
  final DateTime timestamp;
  final String? imagePath;
  final int objectCount;
  final double? confidence;

  HistoryItem({
    this.id,
    required this.type,
    required this.title,
    required this.content,
    this.translatedContent,
    this.detectedLanguage,
    this.targetLanguage,
    required this.timestamp,
    this.imagePath,
    this.objectCount = 0,
    this.confidence,
  });

  String get typeLabel {
    switch (type) {
      case ScanType.ocr: return 'OCR';
      case ScanType.detection: return 'Détection';
      case ScanType.obstacle: return 'Obstacle';
    }
  }

  String get subtitle {
    switch (type) {
      case ScanType.ocr:
        final lines = content.split('\n').length;
        final lang = detectedLanguage?.toUpperCase() ?? 'FR';
        final target = targetLanguage?.toUpperCase() ?? '';
        return target.isNotEmpty ? 'OCR · $lang → $target · $lines lignes' : 'OCR · $lang · $lines lignes';
      case ScanType.detection:
        return 'Détection · $objectCount objet${objectCount > 1 ? 's' : ''} identifié${objectCount > 1 ? 's' : ''}';
      case ScanType.obstacle:
        final conf = confidence != null ? '${(confidence! * 100).toStringAsFixed(0)}% confiance' : '';
        return 'Obstacle · $conf · Alerte vibrée';
    }
  }

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2,'0')}:${timestamp.minute.toString().padLeft(2,'0')}';
    }
    if (diff.inDays == 1) return 'Hier';
    return '${timestamp.day}/${timestamp.month}';
  }

  Map<String, dynamic> toMap() => {
    'type': type.index,
    'title': title,
    'content': content,
    'translated_content': translatedContent,
    'detected_language': detectedLanguage,
    'target_language': targetLanguage,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'image_path': imagePath,
    'object_count': objectCount,
    'confidence': confidence,
  };

  factory HistoryItem.fromMap(Map<String, dynamic> map) => HistoryItem(
    id: map['id'],
    type: ScanType.values[map['type']],
    title: map['title'],
    content: map['content'],
    translatedContent: map['translated_content'],
    detectedLanguage: map['detected_language'],
    targetLanguage: map['target_language'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    imagePath: map['image_path'],
    objectCount: map['object_count'] ?? 0,
    confidence: map['confidence'],
  );
}
