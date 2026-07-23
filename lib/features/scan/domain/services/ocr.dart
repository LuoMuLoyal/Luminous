import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

TextRecognitionScript ocrScriptForLocale(Locale locale) {
  return locale.languageCode == 'zh'
      ? TextRecognitionScript.chinese
      : TextRecognitionScript.latin;
}

class OcrService {
  const OcrService();

  Future<String> recognizeText(
    XFile image, {
    Locale locale = const Locale('zh'),
  }) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: ocrScriptForLocale(locale));
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      await textRecognizer.close();
    }
  }
}
