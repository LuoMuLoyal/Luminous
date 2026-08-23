import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

import '../entities/doc_type.dart';
import '../entities/document.dart';

/// Repository interface for fetching legal documents.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right. A legal
/// empty document list stays a Right, as does the documented 404 → bundled
/// assets fallback (legal/compliance pages must stay viewable even when the
/// server has not published a document yet).
abstract interface class LegalRepository {
  /// Returns all active legal document summaries.
  TaskEither<LucentFailure, List<LegalDocumentSummary>> findAll();

  /// Returns the full content of a specific legal document.
  ///
  /// A missing document (404) falls back to the bundled asset when present;
  /// when that asset is absent too, the failure surfaces as a Left.
  TaskEither<LucentFailure, LegalDocument> findOne(LegalDocType docType);
}
