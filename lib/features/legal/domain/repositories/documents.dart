import '../entities/doc_type.dart';
import '../entities/document.dart';

/// Repository interface for fetching legal documents.
abstract class LegalRepository {
  /// Returns all active legal document summaries.
  Future<List<LegalDocumentSummary>> findAll();

  /// Returns the full content of a specific legal document.
  ///
  /// Throws if the document type is not found.
  Future<LegalDocument> findOne(LegalDocType docType);
}
