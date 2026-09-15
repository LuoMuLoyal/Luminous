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
    bool large = false,
  }) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: MealAnalysisStatusBadge(status: status, large: large),
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

    testWidgets('renders analyzed status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'analyzed');

      expect(find.text(l10n.recordMealAnalysisStatusAnalyzed), findsOneWidget);
    });

    testWidgets('renders analysis_failed status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'analysis_failed');

      expect(find.text(l10n.recordMealAnalysisStatusFailed), findsOneWidget);
    });

    testWidgets('falls back to analyzed for a null status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: null);

      expect(find.text(l10n.recordMealAnalysisStatusAnalyzed), findsOneWidget);
    });

    testWidgets('falls back to analyzed for an unknown status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpBadge(tester, status: 'unknown_status');

      expect(find.text(l10n.recordMealAnalysisStatusAnalyzed), findsOneWidget);
    });

    testWidgets('renders an icon for every status', (tester) async {
      await pumpBadge(tester, status: 'analyzing');
      expect(find.byIcon(SemanticIcons.statusPending), findsOneWidget);

      await pumpBadge(tester, status: 'analyzed');
      expect(find.byIcon(SemanticIcons.reportAdherence), findsOneWidget);

      await pumpBadge(tester, status: 'analysis_failed');
      expect(find.byIcon(SemanticIcons.statusError), findsOneWidget);
    });

    testWidgets('renders FBadge', (tester) async {
      await pumpBadge(tester, status: 'analyzed');

      expect(find.byType(FBadge), findsOneWidget);
    });
  });
}
