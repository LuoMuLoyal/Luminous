import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
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
/// Strategy: remote-first. If the API returns 404 (document not found), the
/// repository falls back to the bundled Markdown assets in `assets/legal/`.
/// This 404 → fallback is the documented product contract for legal/compliance
/// pages (远程优先 + assets fallback, `plans/2026-07-10-legal-compliance-pages.md`
/// P2-2): the pages must stay viewable even when the server has not published
/// a document yet. The fallback is an alternative success path — a Right — and
/// is observed via [appTalker] ("记录+继续"); it is not a catch-all. Network
/// errors, 5xx and other 4xx are rethrown into the mapper and become a Left.
/// In `findAll` a missing bundled asset is skipped with a [appTalker] warning;
/// in `findOne` a missing bundled asset surfaces as a Left(unknown).
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response (including the 404
/// fallback result and a legal empty list) is a Right. An empty success
/// response body is a `LucentFailure.network(emptyResponse)` (settings /
/// notification `_requireData` precedent). Protocol violations (non
/// `problem+json` error bodies) keep the mapper's `FormatException` which
/// propagates from `.run()`.
class LucentLegalRepository implements LegalRepository {
  LucentLegalRepository({required this.api, required this.localeResolver});

  final LegalDocumentsApi api;
  final String Function() localeResolver;

  @override
  TaskEither<LucentFailure, List<LegalDocumentSummary>> findAll() {
    return TaskEither.tryCatch(() async {
      try {
        final response = await api.listLegalDocuments(
          lang: localeResolver(),
        );
        final dto = _requireData(response.data, operation: 'findAll');
        return dto.items
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
          // 文档化 best-effort 合同:404 回退内置资产（记录+继续）。
          appTalker.warning('LucentLegalRepository: findAll 404, 回退内置资产');
          return _fallbackSummaries();
        }
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, LegalDocument> findOne(LegalDocType docType) {
    return TaskEither.tryCatch(() async {
      try {
        final response = await api.getLegalDocument(
          docType: docType.pathSegment,
          lang: localeResolver(),
        );
        final d = _requireData(response.data, operation: 'findOne');
        return LegalDocument(
          docType: docType,
          title: d.title,
          content: d.content,
          updatedAt: d.updatedAt,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          appTalker.warning('LucentLegalRepository: findOne 404, 回退内置资产');
          return _fallbackDocument(docType);
        }
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (settings / notification `_requireData` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
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
      } catch (e) {
        appTalker.warning(
          'LucentLegalRepository: fallback asset not found: $e',
        );
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
