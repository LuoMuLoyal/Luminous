import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/data/repositories/lucent_ai.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/presentation/pages/page.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

void main() {
  testWidgets(
    'Today summary shows preview hint and hides generate action when signed out',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
            todayRepositoryProvider.overrideWithValue(
              const MockTodayRepository(),
            ),
            todaySuggestionProvider.overrideWith(
              EmptyTodaySuggestionNotifier.new,
            ),
          ],
          child: const TestForuiApp(home: TodayPage()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await _scrollToSummaryCard(tester);
      await _expandAiBullets(tester, l10n);

      expect(find.text(l10n.todayAiSummaryPreviewHint), findsOneWidget);
      expect(
        find.widgetWithText(FButton, l10n.todayAiSummaryGenerateAction),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Today summary shows settings action when AI summaries are disabled',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            todayRepositoryProvider.overrideWithValue(
              const MockTodayRepository(),
            ),
            userSettingsControllerProvider.overrideWith(
              DisabledUserSettingsController.new,
            ),
            todaySuggestionProvider.overrideWith(
              EmptyTodaySuggestionNotifier.new,
            ),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
          ],
          child: const TestForuiApp(home: TodayPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await _scrollToSummaryCard(tester);
      await _expandAiBullets(tester, l10n);

      expect(find.text(l10n.todayAiSummaryDisabledHint), findsOneWidget);
      expect(
        find.widgetWithText(FButton, l10n.todayAiSummaryOpenSettingsAction),
        findsOneWidget,
      );
    },
  );

  testWidgets('Today summary renders generated summary after manual action', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final repository = FakeTodayAiRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(repository),
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: TodayPage()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await _scrollToSummaryCard(tester);

    final generateButton = find.widgetWithText(
      FButton,
      l10n.todayAiSummaryGenerateAction,
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      generateButton,
      220,
      scrollable: find
          .descendant(
            of: find.byKey(
              const PageStorageKey<String>('today-dashboard-scroll'),
            ),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(generateButton);
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.widgetWithText(FButton, l10n.todayAiSummaryGeneratingAction),
      findsOneWidget,
    );

    repository.complete(
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: '今天的节奏基本稳定，先把剩余饮水和待确认用药处理掉。',
        bullets: const [
          TodayAiAnalysisBullet(
            kind: TodayAiAnalysisBulletKind.medication,
            text: '还有 1 项今日用药待确认，先核对是否已经服用。',
          ),
          TodayAiAnalysisBullet(
            kind: TodayAiAnalysisBulletKind.hydration,
            text: '饮水距离目标还差 2 次，下午和晚间各补一次。',
          ),
        ],
        actionLabel: '查看今日记录',
        confidenceNote: '仅基于今日已记录数据生成，不构成诊断或治疗建议。',
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('今天的节奏基本稳定，先把剩余饮水和待确认用药处理掉。'), findsOneWidget);
    await _expandAiBullets(tester, l10n);
    expect(find.text('还有 1 项今日用药待确认，先核对是否已经服用。'), findsOneWidget);
    expect(find.text('饮水距离目标还差 2 次，下午和晚间各补一次。'), findsOneWidget);
    expect(find.text('仅基于今日已记录数据生成，不构成诊断或治疗建议。'), findsOneWidget);
  });
}

Future<void> _scrollToSummaryCard(WidgetTester tester) async {
  // ShellDeferredContent defers content to the next frame; after the content
  // is built, async providers (todayDashboardProvider) start and need one
  // more frame for their data to propagate to the widget tree.
  await tester.pump();
  await tester.scrollUntilVisible(
    find.byKey(const Key('today-summary-card')),
    220,
    scrollable: find
        .descendant(
          of: find.byKey(
            const PageStorageKey<String>('today-dashboard-scroll'),
          ),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pump(const Duration(milliseconds: 200));
}

/// Taps the AI bullets expand button so bullet text becomes visible.
///
/// The [TodaySummarySection] collapses AI bullets by default; tests that
/// assert on bullet text must expand first.
Future<void> _expandAiBullets(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  final expandButton = find.text(l10n.todaySuggestionShowEvidence);
  await tester.scrollUntilVisible(
    expandButton,
    220,
    scrollable: find
        .descendant(
          of: find.byKey(
            const PageStorageKey<String>('today-dashboard-scroll'),
          ),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(expandButton);
  await tester.pump(const Duration(milliseconds: 300));
}
