import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/legal/data/repositories/lucent.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/domain/entities/document.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:luminous/features/legal/presentation/pages/detail.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

class _FakeLegalRepository implements LegalRepository {
  _FakeLegalRepository(this._documents, this._summaries);

  final Map<LegalDocType, LegalDocument> _documents;
  final List<LegalDocumentSummary> _summaries;

  @override
  Future<List<LegalDocumentSummary>> findAll() async => _summaries;

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    if (_documents.containsKey(docType)) return _documents[docType]!;
    throw Exception('Document not found');
  }
}

class _ThrowingLegalRepository implements LegalRepository {
  @override
  Future<List<LegalDocumentSummary>> findAll() async => throw Exception('err');

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async =>
      throw Exception('Network error');
}

void main() {
  group('LegalDetailPage', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      required String docType,
      Map<LegalDocType, LegalDocument> documents = const {},
      bool throwOnError = false,
    }) async {
      final repo = throwOnError
          ? _ThrowingLegalRepository()
          : _FakeLegalRepository(documents, const []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [legalRepositoryProvider.overrideWithValue(repo)],
          child: TestForuiApp(home: LegalDetailPage(docType: docType)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, docType: 'terms');

      expect(find.text(l10n.legalDetailTitle), findsOneWidget);
    });

    testWidgets('renders markdown content when loaded', (tester) async {
      await pumpPage(
        tester,
        docType: 'terms',
        documents: {
          LegalDocType.terms: const LegalDocument(
            docType: LegalDocType.terms,
            title: '用户协议',
            content: '# 用户协议\n\n请仔细阅读。',
            updatedAt: '2026-01-01',
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.text('用户协议'), findsWidgets);
      expect(find.text('请仔细阅读。'), findsOneWidget);
    });

    testWidgets('renders not found error for invalid docType', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, docType: 'invalid-type');

      expect(find.text(l10n.legalNotFoundTitle), findsOneWidget);
    });

    testWidgets('renders back to list action for invalid docType', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, docType: 'invalid-type');

      expect(find.text(l10n.legalBackToListAction), findsOneWidget);
    });

    testWidgets('renders error state on fetch failure', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, docType: 'terms', throwOnError: true);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(l10n.legalLoadErrorTitle), findsOneWidget);
    });

    testWidgets('renders retry action on fetch failure', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, docType: 'privacy', throwOnError: true);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(l10n.legalRetryAction), findsOneWidget);
    });

    testWidgets('renders privacy document content', (tester) async {
      await pumpPage(
        tester,
        docType: 'privacy',
        documents: {
          LegalDocType.privacy: const LegalDocument(
            docType: LegalDocType.privacy,
            title: '隐私政策',
            content: '# 隐私政策\n\n我们保护您的隐私。',
            updatedAt: '2026-06-01',
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.text('隐私政策'), findsWidgets);
      expect(find.text('我们保护您的隐私。'), findsOneWidget);
    });

    testWidgets('renders disclaimer document content', (tester) async {
      await pumpPage(
        tester,
        docType: 'disclaimer',
        documents: {
          LegalDocType.disclaimer: const LegalDocument(
            docType: LegalDocType.disclaimer,
            title: '医疗免责声明',
            content: '# 医疗免责声明\n\n本应用不提供医疗建议。',
            updatedAt: '2026-06-01',
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.text('医疗免责声明'), findsWidgets);
      expect(find.text('本应用不提供医疗建议。'), findsOneWidget);
    });

    testWidgets('renders minor-protection document content', (tester) async {
      await pumpPage(
        tester,
        docType: 'minor-protection',
        documents: {
          LegalDocType.minorProtection: const LegalDocument(
            docType: LegalDocType.minorProtection,
            title: '未成年人保护',
            content: '# 未成年人保护\n\n14岁以下不面向。',
            updatedAt: '2026-06-01',
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.text('未成年人保护'), findsWidgets);
    });

    testWidgets('renders account-cancellation document content', (
      tester,
    ) async {
      await pumpPage(
        tester,
        docType: 'account-cancellation',
        documents: {
          LegalDocType.accountCancellation: const LegalDocument(
            docType: LegalDocType.accountCancellation,
            title: '注销政策',
            content: '# 注销政策\n\n联系客服注销。',
            updatedAt: '2026-06-01',
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.text('注销政策'), findsWidgets);
    });
  });
}
