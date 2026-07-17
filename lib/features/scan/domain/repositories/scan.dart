import 'package:luminous/features/scan/domain/entities/scan_result.dart';

abstract interface class ScanRepository {
  Future<List<ScanSearchResult>> search(String query);

  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  });

  Future<MedicineRecognitionResult> recognizeMedicine(String imageUrl);
}
