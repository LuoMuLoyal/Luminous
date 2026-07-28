import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_status_badge.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

void main() {
  Future<void> pumpBadge(
    WidgetTester tester, {
    String? status,
    String? coverage,
    bool large = false,
  }) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MealAnalysisStatusBadge(
            status: status,
            coverage: coverage,
            large: large,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('MealAnalysisStatusBadge', () {
    testWidgets('renders analyzing status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'analyzing');

      expect(find.text(l10n.recordMealAnalysisStatusAnalyzing), findsOneWidget);
    });

    testWidgets('renders confirmed status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'confirmed');

      expect(find.text(l10n.recordMealAnalysisStatusConfirmed), findsOneWidget);
    });

    testWidgets('renders analysis_failed status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'analysis_failed');

      expect(find.text(l10n.recordMealAnalysisStatusFailed), findsOneWidget);
    });

    testWidgets('renders unconfirmed status for null', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: null);

      expect(
        find.text(l10n.recordMealAnalysisStatusUnconfirmed),
        findsOneWidget,
      );
    });

    testWidgets('renders unconfirmed status for unknown string', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'unknown_status');

      expect(
        find.text(l10n.recordMealAnalysisStatusUnconfirmed),
        findsOneWidget,
      );
    });

    testWidgets('appends coverage complete label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'confirmed', coverage: 'complete');

      expect(
        find.textContaining(l10n.recordMealAnalysisCoverageComplete),
        findsOneWidget,
      );
    });

    testWidgets('appends coverage none label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'confirmed', coverage: 'none');

      expect(
        find.textContaining(l10n.recordMealAnalysisCoverageNone),
        findsOneWidget,
      );
    });

    testWidgets('appends coverage partial label', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'confirmed', coverage: 'partial');

      expect(
        find.textContaining(l10n.recordMealAnalysisCoveragePartial),
        findsOneWidget,
      );
    });

    testWidgets('does not append coverage for unknown value', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'confirmed', coverage: 'unknown');

      expect(find.text(l10n.recordMealAnalysisStatusConfirmed), findsOneWidget);
    });

    testWidgets('renders with · separator when coverage is present', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'confirmed', coverage: 'complete');

      final expected =
          '${l10n.recordMealAnalysisStatusConfirmed} · ${l10n.recordMealAnalysisCoverageComplete}';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('renders icon for analyzing status', (tester) async {
      await pumpBadge(tester, status: 'analyzing');

      expect(find.byIcon(SemanticIcons.statusPending), findsOneWidget);
    });

    testWidgets('renders icon for confirmed status', (tester) async {
      await pumpBadge(tester, status: 'confirmed');

      expect(find.byIcon(SemanticIcons.reportAdherence), findsOneWidget);
    });

    testWidgets('renders icon for failed status', (tester) async {
      await pumpBadge(tester, status: 'analysis_failed');

      expect(find.byIcon(SemanticIcons.statusError), findsOneWidget);
    });

    testWidgets('renders icon for unconfirmed status', (tester) async {
      await pumpBadge(tester, status: null);

      expect(find.byIcon(SemanticIcons.actionHelp), findsOneWidget);
    });

    testWidgets('renders FBadge', (tester) async {
      await pumpBadge(tester, status: 'confirmed');

      expect(find.byType(FBadge), findsOneWidget);
    });
  });
}
