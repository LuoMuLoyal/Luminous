import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/doc_type.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/documents.dart';

part 'lucent.g.dart';

@riverpod
LegalRepository legalRepository(Ref ref) {
  return LucentLegalRepository(
    api: ref.watch(lucentClientProvider).legalDocuments,
    localeResolver: () =>
        (ref.read(localeControllerProvider).asData?.value ?? AppLocale.system)
            .acceptLanguage
            .startsWith('en')
        ? 'en'
        : 'zh',
  );
}

/// Lucent-backed implementation of [LegalRepository].
///
/// Strategy: remote-first. If the API returns 404 (document not found),
/// falls back to bundled Markdown assets in `assets/legal/`.
/// Network errors, 500s, and other non-404 exceptions are rethrown so the
/// UI can display a proper error state with retry.
class LucentLegalRepository implements LegalRepository {
  LucentLegalRepository({required this.api, required this.localeResolver});

  final LegalDocumentsApi api;
  final String Function() localeResolver;

  @override
  Future<List<LegalDocumentSummary>> findAll() async {
    try {
      final response = await api.legalDocumentsControllerFindAllV1(
        lang: localeResolver(),
      );
      return response.data!.data.items
          .map(
            (item) => LegalDocumentSummary(
              docType:
                  LegalDocType.fromPathSegment(item.docType) ??
                  LegalDocType.terms,
              title: item.title,
              updatedAt: item.updatedAt,
            ),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _fallbackSummaries();
      }
      rethrow;
    }
  }

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    try {
      final response = await api.legalDocumentsControllerFindOneV1(
        docType: docType.pathSegment,
        lang: localeResolver(),
      );
      final d = response.data!.data;
      return LegalDocument(
        docType: docType,
        title: d.title,
        content: d.content,
        updatedAt: d.updatedAt,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _fallbackDocument(docType);
      }
      rethrow;
    }
  }

  // -- Fallback data from bundled assets --

  Future<List<LegalDocumentSummary>> _fallbackSummaries() async {
    final lang = localeResolver();
    final suffix = lang == 'en' ? '_en' : '_zh';
    final results = <LegalDocumentSummary>[];
    for (final type in LegalDocType.values) {
      final assetPath = 'assets/legal/${type.pathSegment}$suffix.md';
      try {
        final content = await rootBundle.loadString(assetPath);
        final firstLine = content
            .split('\n')
            .firstWhere(
              (line) => line.trim().startsWith('#'),
              orElse: () => '',
            );
        final title = firstLine.replaceAll('#', '').trim();
        results.add(
          LegalDocumentSummary(
            docType: type,
            title: title.isEmpty ? type.pathSegment : title,
            updatedAt: '',
          ),
        );
      } catch (_) {
        // Asset not found — skip this document.
      }
    }
    return results;
  }

  Future<LegalDocument> _fallbackDocument(LegalDocType docType) async {
    final lang = localeResolver();
    final suffix = lang == 'en' ? '_en' : '_zh';
    final assetPath = 'assets/legal/${docType.pathSegment}$suffix.md';
    final content = await rootBundle.loadString(assetPath);
    final firstLine = content
        .split('\n')
        .firstWhere((line) => line.trim().startsWith('#'), orElse: () => '');
    final title = firstLine.replaceAll('#', '').trim();
    return LegalDocument(
      docType: docType,
      title: title.isEmpty ? docType.pathSegment : title,
      content: content,
      updatedAt: '',
    );
  }
}
