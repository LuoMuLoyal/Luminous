import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/features/legal/data/repositories/lucent.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/domain/entities/document.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:luminous/features/legal/presentation/pages/list.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

class _FakeLegalRepository implements LegalRepository {
  _FakeLegalRepository(this._summaries);

  final List<LegalDocumentSummary> _summaries;

  @override
  TaskEither<LucentFailure, List<LegalDocumentSummary>> findAll() {
    return TaskEither.right(_summaries);
  }

  @override
  TaskEither<LucentFailure, LegalDocument> findOne(LegalDocType docType) {
    throw UnimplementedError('Not used in list page tests');
  }
}

class _FailingLegalRepository implements LegalRepository {
  @override
  TaskEither<LucentFailure, List<LegalDocumentSummary>> findAll() {
    return TaskEither.left(
      LucentFailure.network(
        message: 'Network error',
        networkErrorCode: NetworkErrorCode.connectionError,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, LegalDocument> findOne(LegalDocType docType) {
    return TaskEither.left(
      LucentFailure.network(
        message: 'Network error',
        networkErrorCode: NetworkErrorCode.connectionError,
      ),
    );
  }
}

void main() {
  group('LegalListPage', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      List<LegalDocumentSummary> summaries = const [],
      Object? error,
    }) async {
      final repo = error != null
          ? _FailingLegalRepository()
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

      expect(find.byIcon(SemanticIcons.recordNote), findsWidgets);
      expect(find.byIcon(SemanticIcons.safetyNeutral), findsOneWidget);
      expect(find.byIcon(SemanticIcons.statusInfo), findsOneWidget);
      expect(find.byIcon(SemanticIcons.safetySpecialGroup), findsOneWidget);
      expect(find.byIcon(SemanticIcons.tabRecord), findsOneWidget);
      expect(find.byIcon(SemanticIcons.statusBlocked), findsOneWidget);
      expect(find.byIcon(SemanticIcons.profileUser), findsOneWidget);
    });
  });
}
