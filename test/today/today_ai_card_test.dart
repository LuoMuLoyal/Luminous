import '../helpers/test_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/data/repositories/lucent_today_ai_repository.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'today_test_helpers.dart';

void main() {
  testWidgets('Today AI card shows signed-out hint and keeps generate action', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(l10n.todayAiSummarySignedOutHint),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.widgetWithText(TextButton, l10n.todayAiSummaryGenerateAction),
      findsOneWidget,
    );
  });

  testWidgets(
    'Today AI card shows settings action when AI summaries are disabled',
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
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('zh'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TodayPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(l10n.todayAiSummaryDisabledHint),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.widgetWithText(TextButton, l10n.todayAiSummaryOpenSettingsAction),
        findsOneWidget,
      );
    },
  );

  testWidgets('Today AI card renders generated summary after manual action', (
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
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TodayPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextButton, l10n.todayAiSummaryGenerateAction),
      findsOneWidget,
    );

    await tester.tap(
      find.widgetWithText(TextButton, l10n.todayAiSummaryGenerateAction),
    );
    await tester.pump();

    expect(
      find.widgetWithText(TextButton, l10n.todayAiSummaryGeneratingAction),
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

    await tester.pumpAndSettle();

    expect(find.text('今天的节奏基本稳定，先把剩余饮水和待确认用药处理掉。'), findsOneWidget);
    expect(find.text('还有 1 项今日用药待确认，先核对是否已经服用。'), findsOneWidget);
    expect(find.text('饮水距离目标还差 2 次，下午和晚间各补一次。'), findsOneWidget);
    expect(find.text('仅基于今日已记录数据生成，不构成诊断或治疗建议。'), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, l10n.todayAiSummaryGenerateAction),
      findsOneWidget,
    );
  });
}
