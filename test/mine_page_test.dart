import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/mine/presentation/mine_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Mine page renders mobile mock sections', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpMinePage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = find.byType(Scrollable).first;
    final keys = <String>[
      'mine-account-header',
      'mine-health-summary',
      'mine-profile-grid',
      'mine-plan-center',
      'mine-report-privacy',
      'mine-settings',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 200));
      expect(finder, findsOneWidget);
    }

    expect(find.text('Lumi 用户'), findsOneWidget);
    expect(find.text('健康上下文摘要'), findsOneWidget);
    expect(find.text('健康档案'), findsOneWidget);
    expect(find.text('健康计划中心'), findsOneWidget);
    expect(find.text('健康报告'), findsOneWidget);
    expect(find.text('隐私控制'), findsOneWidget);
    expect(find.text('设置与支持'), findsOneWidget);
  });

  testWidgets('Mine page renders desktop side panels', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpMinePage(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('mine-status-panel')), findsOneWidget);
    expect(find.byKey(const Key('mine-onboarding-panel')), findsOneWidget);
    expect(find.byKey(const Key('mine-quick-entries-panel')), findsOneWidget);
    expect(find.byKey(const Key('mine-settings-panel')), findsOneWidget);
    expect(find.text('档案状态'), findsOneWidget);
    expect(find.text('Onboarding 进度'), findsOneWidget);
    expect(find.text('快捷入口'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
  });

  testWidgets('Mine page renders signed-out static view without loading', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => _SignedOutAuthSessionNotifier()),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => throw Exception('should not fetch when signed out'),
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
          home: const MinePage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('当前未登录'), findsOneWidget);
    expect(find.text('访客'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
    expect(find.text('去登录'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.text('我的页面暂时没有加载出来'), findsNothing);
  });
}

Future<void> _pumpMinePage(WidgetTester tester) async {
  final mockSnapshot = HealthContextSnapshot(
    summary: const HealthSummary(
      age: 27,
      onboardingCompleted: true,
      activeAllergyCount: 2,
      conditionCount: 1,
      currentMedicineCount: 3,
      missingCoreProfileFields: ['bloodType'],
    ),
    profile: const HealthProfile(
      birthDate: '1999-01-15',
      sexAtBirth: null,
      heightCm: null,
      pregnancyState: null,
      lactationState: null,
      bloodType: null,
      locale: null,
      timezone: null,
      unitSystem: null,
      onboardingCompletedAt: '2026-01-01T00:00:00Z',
      extras: {},
    ),
    allergies: const [],
    conditions: const [],
    currentMedicines: const [],
  );

  await tester.pumpWidget(
      ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
        healthContextSnapshotProvider
            .overrideWith((ref) => Future.value(mockSnapshot)),
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
        home: const MinePage(),
      ),
    ),
  );
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
    );
  }
}
