import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:lucent_api/api/export.dart';

import '../../domain/entities/legal_doc_type.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/repositories/legal_repository.dart';

/// Riverpod provider for [LegalRepository].
final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LucentLegalRepository(
    api: ref.watch(lucentClientProvider).legalDocuments,
    localeResolver: () =>
        (ref.read(appLocaleControllerProvider).asData?.value ??
                AppLocale.system)
            .acceptLanguage
            .startsWith('en')
        ? Lang.en
        : Lang.zh,
  );
});

/// Lucent-backed implementation of [LegalRepository].
///
/// Strategy: remote-first. If the API call fails (network error, 404, etc.),
/// falls back to bundled Markdown assets in `assets/legal/`.
class LucentLegalRepository implements LegalRepository {
  LucentLegalRepository({required this.api, required this.localeResolver});

  final LegalDocumentsApi api;
  final Lang Function() localeResolver;

  @override
  Future<List<LegalDocumentSummary>> findAll() async {
    try {
      final response = await api.legalDocumentsControllerFindAllV1(
        lang: localeResolver(),
      );
      return response.data.items
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
    } catch (_) {
      return _fallbackSummaries();
    }
  }

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    try {
      final response = await api.legalDocumentsControllerFindOneV1(
        docType: docType.pathSegment,
        lang: localeResolver(),
      );
      final d = response.data;
      return LegalDocument(
        docType: docType,
        title: d.title,
        content: d.content,
        updatedAt: d.updatedAt,
      );
    } catch (_) {
      return _fallbackDocument(docType);
    }
  }

  // -- Fallback data from bundled assets --

  Future<List<LegalDocumentSummary>> _fallbackSummaries() async {
    final lang = localeResolver();
    final suffix = lang == Lang.en ? '_en' : '_zh';
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
    final suffix = lang == Lang.en ? '_en' : '_zh';
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
