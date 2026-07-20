import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/domain/entities/document.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:luminous/features/legal/presentation/pages/list.dart';
import 'package:luminous/features/legal/presentation/providers/legal.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

class _FakeLegalRepository implements LegalRepository {
  _FakeLegalRepository(this._summaries);

  final List<LegalDocumentSummary> _summaries;

  @override
  Future<List<LegalDocumentSummary>> findAll() async => _summaries;

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    throw Exception('Not used in list page tests');
  }
}

class _ThrowingLegalRepository implements LegalRepository {
  _ThrowingLegalRepository(this.error);
  final Object error;

  @override
  Future<List<LegalDocumentSummary>> findAll() async => throw error;

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async => throw error;
}

void main() {
  group('LegalListPage', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      List<LegalDocumentSummary> summaries = const [],
      Object? error,
    }) async {
      final repo = error != null
          ? _ThrowingLegalRepository(error)
          : _FakeLegalRepository(summaries);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [legalRepositoryProvider.overrideWithValue(repo)],
          child: const TestForuiApp(home: LegalListPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('renders page title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester);

      expect(find.text(l10n.legalListTitle), findsOneWidget);
    });

    testWidgets('renders document tiles when data loaded', (tester) async {
      await pumpPage(
        tester,
        summaries: [
          const LegalDocumentSummary(
            docType: LegalDocType.terms,
            title: '用户协议',
            updatedAt: '2026-01-01',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.privacy,
            title: '隐私政策',
            updatedAt: '2026-01-02',
          ),
        ],
      );

      expect(find.text('用户协议'), findsOneWidget);
      expect(find.text('隐私政策'), findsOneWidget);
    });

    testWidgets('renders updated date subtitle', (tester) async {
      const testLocale = Locale('zh');
      final l10n = await AppLocalizations.delegate.load(testLocale);
      const testDate = '2026-01-15T10:30:00Z';
      await pumpPage(
        tester,
        summaries: [
          const LegalDocumentSummary(
            docType: LegalDocType.terms,
            title: '用户协议',
            updatedAt: testDate,
          ),
        ],
      );

      final formatted = formatDateTimeLabel(testDate, testLocale);
      expect(find.text(l10n.legalListUpdatedAt(formatted)), findsOneWidget);
    });

    testWidgets('hides subtitle when updatedAt is empty', (tester) async {
      await pumpPage(
        tester,
        summaries: [
          const LegalDocumentSummary(
            docType: LegalDocType.terms,
            title: '用户协议',
            updatedAt: '',
          ),
        ],
      );

      expect(find.byType(FTile), findsOneWidget);
    });

    testWidgets('renders empty state when no documents', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, summaries: []);

      expect(find.text(l10n.legalListEmptyTitle), findsOneWidget);
    });

    testWidgets('renders error state on failure', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, error: Exception('Network error'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(l10n.legalLoadErrorTitle), findsOneWidget);
    });

    testWidgets('renders retry action in error state', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpPage(tester, error: Exception('Network error'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(l10n.legalRetryAction), findsOneWidget);
    });

    testWidgets('renders all 7 doc type icons', (tester) async {
      await pumpPage(
        tester,
        summaries: [
          const LegalDocumentSummary(
            docType: LegalDocType.terms,
            title: 'T',
            updatedAt: '',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.privacy,
            title: 'P',
            updatedAt: '',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.disclaimer,
            title: 'D',
            updatedAt: '',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.minorProtection,
            title: 'M',
            updatedAt: '',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.sdkList,
            title: 'S',
            updatedAt: '',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.permissions,
            title: 'PE',
            updatedAt: '',
          ),
          const LegalDocumentSummary(
            docType: LegalDocType.accountCancellation,
            title: 'A',
            updatedAt: '',
          ),
        ],
      );

      expect(find.byIcon(FLucideIcons.fileText), findsWidgets);
      expect(find.byIcon(FLucideIcons.shield), findsOneWidget);
      expect(find.byIcon(FLucideIcons.info), findsOneWidget);
      expect(find.byIcon(FLucideIcons.baby), findsOneWidget);
      expect(find.byIcon(FLucideIcons.list), findsOneWidget);
      expect(find.byIcon(FLucideIcons.key), findsOneWidget);
      expect(find.byIcon(FLucideIcons.userMinus), findsOneWidget);
    });
  });
}
