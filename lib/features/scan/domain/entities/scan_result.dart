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
