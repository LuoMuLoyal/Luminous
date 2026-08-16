import 'dart:ui';

/// Domain entity for a medicine search result from barcode/OCR/AI scan.
class ScanSearchResult {
  const ScanSearchResult({required this.id, required this.name, this.subtitle});

  final String id;
  final String name;
  final String? subtitle;
}

/// Domain entity for AI medicine recognition result.
class MedicineRecognitionResult {
  const MedicineRecognitionResult({required this.name, this.approvalNumber});

  final String name;
  final String? approvalNumber;
}

/// A single text region recognized by OCR, with spatial and confidence metadata.
///
/// This is the domain-level abstraction over the platform-specific OCR result,
/// enabling unit testing without the native OCR plugin.
class OcrTextBlock {
  const OcrTextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    required this.points,
  });

  final String text;
  final double confidence;
  final Rect boundingBox;
  final List<Offset> points; // Four-point polygon in source-image pixels
}

/// How a medicine match was found.
enum MedicineMatchType { approvalNumber, nameFuzzy }

/// Recognition method used for a photo scan.
///
/// Shared by the scan flow ([box_scan] picker) and the recognition result
/// dialog so the dialog can show method-specific copy without string
/// matching.
enum MedicineScanMethod { ocr, ai }

/// A candidate extracted from OCR text, to be searched against the medicine DB.
class MedicineMatchCandidate {
  const MedicineMatchCandidate({
    required this.query,
    required this.confidence,
    required this.matchType,
  });

  final String query;
  final double confidence;
  final MedicineMatchType matchType;
}

/// Final result after matching OCR text against the medicine database.
class MedicineMatchResult {
  const MedicineMatchResult({
    required this.name,
    this.approvalNumber,
    this.id,
    this.confidence,
    required this.matchType,
  });

  final String name;
  final String? approvalNumber;
  final String? id;

  /// Candidate ordering score from the recognition path (OCR reports the
  /// engine's real score). Used only to sort the candidate list (null sorts
  /// as 0) — never displayed as a percentage. The AI recognition path has no
  /// score from the backend, so it stays null instead of fabricating one.
  final double? confidence;

  final MedicineMatchType matchType;
}
