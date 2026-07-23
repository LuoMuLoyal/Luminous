import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/lucent.dart';
import '../../domain/entities/doc_type.dart';
import '../../domain/entities/document.dart';

/// Re-export so presentation code can import from one place.
export '../../data/repositories/lucent.dart' show legalRepositoryProvider;

part 'legal.g.dart';

/// Fetches all active legal document summaries.
@riverpod
Future<List<LegalDocumentSummary>> legalDocuments(Ref ref) async {
  final repo = ref.watch(legalRepositoryProvider);
  return repo.findAll();
}

/// Fetches the full content of a specific legal document.
@riverpod
Future<LegalDocument> legalDocument(Ref ref, LegalDocType docType) async {
  final repo = ref.watch(legalRepositoryProvider);
  return repo.findOne(docType);
}
