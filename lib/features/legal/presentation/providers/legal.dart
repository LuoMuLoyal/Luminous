import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/lucent.dart';
import '../../domain/entities/doc_type.dart';
import '../../domain/entities/document.dart';

part 'legal.g.dart';

/// Fetches all active legal document summaries.
@riverpod
Future<List<LegalDocumentSummary>> legalDocuments(Ref ref) async {
  final repo = ref.watch(legalRepositoryProvider);
  final result = await repo.findAll().run();
  // Left 投影到 AsyncValue.error（Riverpod 捕获重抛的 failure）。
  return result.fold((failure) => throw failure, (docs) => docs);
}

/// Fetches the full content of a specific legal document.
@riverpod
Future<LegalDocument> legalDocument(Ref ref, LegalDocType docType) async {
  final repo = ref.watch(legalRepositoryProvider);
  final result = await repo.findOne(docType).run();
  return result.fold((failure) => throw failure, (doc) => doc);
}
