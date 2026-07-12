import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/lucent.dart';
import '../../domain/entities/legal_doc_type.dart';
import '../../domain/entities/legal_document.dart';

/// Re-export so presentation code can import from one place.
export '../../data/repositories/lucent.dart' show legalRepositoryProvider;

/// Fetches all active legal document summaries.
final legalDocumentsProvider =
    FutureProvider.autoDispose<List<LegalDocumentSummary>>((ref) async {
      final repo = ref.watch(legalRepositoryProvider);
      return repo.findAll();
    });

/// Fetches the full content of a specific legal document.
final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalDocument, LegalDocType>((ref, docType) async {
      final repo = ref.watch(legalRepositoryProvider);
      return repo.findOne(docType);
    });
