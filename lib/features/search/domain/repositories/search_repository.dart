import 'package:luminous/features/search/domain/entities/search_entities.dart';

/// Repository for medicine search operations.
abstract interface class MedicineSearchRepository {
  /// Search medicines by keyword from a source.
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page,
    int pageSize,
  });

  /// Get medicine detail by id and source.
  Future<MedicineSearchSafetyPreview?> fetchDetail(String id, MedicineSearchSource source);
}
