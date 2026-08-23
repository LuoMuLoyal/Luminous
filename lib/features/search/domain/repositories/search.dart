import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

/// Repository for medicine search operations.
abstract interface class MedicineSearchRepository {
  /// Search medicines by keyword from a source.
  ///
  /// An empty candidate set is a legal Right — no matches is not an error.
  /// Server business failures (4xx/5xx Problem Details) are a Left carrying
  /// the upstream `code`/`status`; network failures are a Left(network).
  TaskEither<LucentFailure, List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page,
    int pageSize,
  });

  /// Get medicine detail by id and source.
  ///
  /// Server business failures (4xx/5xx, e.g. resource not found) are a Left
  /// carrying the Problem Details `code`; a successful response is a Right
  /// with a nullable preview (`null` means no preview data — not an error).
  TaskEither<LucentFailure, MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  );
}
