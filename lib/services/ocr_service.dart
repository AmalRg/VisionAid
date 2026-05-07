import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final OcrService instance = OcrService._();
  OcrService._();

  final TextRecognizer _latin  = TextRecognizer(script: TextRecognitionScript.latin);
  //final TextRecognizer _arabic = TextRecognizer(script: TextRecognitionScript.arabic);

  Future<String> recognizeText(InputImage image) async {
    final latinText  = await _tryRecognize(_latin,  image);
    //final arabicText = await _tryRecognize(_arabic, image);
    //if (arabicText.length > latinText.length + 5) {
      //return arabicText.trim();
    //}
    if (latinText.isNotEmpty) return latinText.trim();
    //if (arabicText.isNotEmpty) return arabicText.trim();
    return '';
  }

  Future<String> _tryRecognize(TextRecognizer recognizer, InputImage image) async {
    try {
      final result = await recognizer.processImage(image);
      return result.text;
    } catch (_) {
      return '';
    }
  }

  void dispose() {
    _latin.close();
    //_arabic.close();
  }
}
