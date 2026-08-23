import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';

/// Repository for barcode/OCR/AI medicine scan operations.
abstract interface class ScanRepository {
  /// Search medicines by barcode or recognized name.
  ///
  /// An empty candidate set is a legal Right — no matches is not an error.
  /// Server business failures (4xx/5xx Problem Details) are a Left carrying
  /// the upstream `code`/`status`; network failures are a Left(network).
  TaskEither<LucentFailure, List<ScanSearchResult>> search(String query);

  /// Upload an image via a presigned URL and return its public URL.
  ///
  /// Server business failures (4xx/5xx Problem Details) are a Left carrying
  /// the upstream `code`/`status`; network failures are a Left(network).
  TaskEither<LucentFailure, String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  });

  /// Recognize medicine info from an uploaded image URL.
  ///
  /// Server business failures (4xx/5xx Problem Details) are a Left carrying
  /// the upstream `code`/`status`; network failures are a Left(network).
  TaskEither<LucentFailure, MedicineRecognitionResult> recognizeMedicine(
    String imageUrl,
  );
}
