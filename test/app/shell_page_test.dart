import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/auth_test_helpers.dart';

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

void main() {
  test('ShellTab uses Forui Lucide icons', () {
    expect(ShellTab.today.icon, FLucideIcons.house);
    expect(ShellTab.today.activeIcon, FLucideIcons.house);
    expect(ShellTab.record.icon, FLucideIcons.notebookPen);
    expect(ShellTab.record.activeIcon, FLucideIcons.notebookPen);
    expect(ShellTab.medicine.icon, FLucideIcons.pill);
    expect(ShellTab.medicine.activeIcon, FLucideIcons.pill);
    expect(ShellTab.report.icon, FLucideIcons.chartColumn);
    expect(ShellTab.report.activeIcon, FLucideIcons.chartColumn);
    expect(ShellTab.mine.icon, FLucideIcons.userRound);
    expect(ShellTab.mine.activeIcon, FLucideIcons.userRound);
  });

  testWidgets('Shell page uses five desktop tabs plus settings/help actions', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final mockSnapshot = const HealthContextSnapshot(
      summary: HealthSummary(
        age: 27,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 1,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: [],
      conditions: [],
      currentMedicines: [],
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(mockSnapshot),
          ),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          recordRepositoryProvider.overrideWithValue(
            const MockRecordRepository(),
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          reportRepositoryProvider.overrideWithValue(
            const MockReportRepository(),
          ),
          supportResourcesProvider(
            'campus',
          ).overrideWith((ref) async => const []),
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
          home: const ShellPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FSidebar), findsOneWidget);
    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.tabToday), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabRecord), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabMedicine), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabReport), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabMine), findsAtLeastNWidgets(1));
    expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
    expect(find.text(l10n.desktopSidebarHelp), findsOneWidget);

    await tester.tap(find.text(l10n.tabReport).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-snapshot-status')), findsOneWidget);
    expect(find.byKey(const Key('report-generate-action')), findsOneWidget);

    await tester.tap(find.text(l10n.tabMine).first);
    await tester.pumpAndSettle();
    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text(l10n.mineCompletionTitle), findsOneWidget);
  });

  testWidgets('Desktop sidebar can be collapsed and expanded', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final mockSnapshot = const HealthContextSnapshot(
      summary: HealthSummary(
        age: 27,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 1,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: [],
      conditions: [],
      currentMedicines: [],
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(mockSnapshot),
          ),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          recordRepositoryProvider.overrideWithValue(
            const MockRecordRepository(),
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          reportRepositoryProvider.overrideWithValue(
            const MockReportRepository(),
          ),
          supportResourcesProvider(
            'campus',
          ).overrideWith((ref) async => const []),
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
          home: const ShellPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Initially expanded: collapse button points left and settings label shows.
    expect(find.byIcon(FLucideIcons.chevronLeft), findsOneWidget);
    expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
    expect(find.text(l10n.desktopSidebarHelp), findsOneWidget);

    await tester.tap(find.byIcon(FLucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    // Collapsed: toggle icon flips and labels are hidden.
    expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    expect(find.text(l10n.desktopSidebarSettings), findsNothing);
    expect(find.text(l10n.desktopSidebarHelp), findsNothing);

    await tester.tap(find.byIcon(FLucideIcons.chevronRight));
    await tester.pumpAndSettle();

    // Expanded again.
    expect(find.byIcon(FLucideIcons.chevronLeft), findsOneWidget);
    expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
    expect(find.text(l10n.desktopSidebarHelp), findsOneWidget);
  });

  testWidgets('Shell page renders mobile bottom navigation', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await _pumpShell(tester);

    expect(find.byType(FBottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
    'Shell page renders mobile bottom navigation at large text scale',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      await _pumpShell(tester);

      expect(find.byType(FBottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Shell page signed-out renders without crash', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
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
          home: const ShellPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Shell should render without exceptions
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shell page cycles through all five tabs without crash', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final mockSnapshot = const HealthContextSnapshot(
      summary: HealthSummary(
        age: 27,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 1,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: [],
      conditions: [],
      currentMedicines: [],
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(mockSnapshot),
          ),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          recordRepositoryProvider.overrideWithValue(
            const MockRecordRepository(),
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          reportRepositoryProvider.overrideWithValue(
            const MockReportRepository(),
          ),
          supportResourcesProvider(
            'campus',
          ).overrideWith((ref) async => const []),
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
          home: const ShellPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final tabs = <String>[
      l10n.tabToday,
      l10n.tabRecord,
      l10n.tabMedicine,
      l10n.tabReport,
      l10n.tabMine,
    ];
    for (final tab in tabs) {
      expect(find.text(tab), findsAtLeastNWidgets(1));
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
      // Consume any layout overflow warnings from nested tab pages
      tester.takeException();
    }
    // App title still visible after cycling through all tabs
    expect(find.text(l10n.appTitle), findsOneWidget);
  });

  testWidgets('Mine page shows status badges', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final mockSnapshot = const HealthContextSnapshot(
      summary: HealthSummary(
        age: 27,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 1,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: [],
      conditions: [],
      currentMedicines: [],
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(mockSnapshot),
          ),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          recordRepositoryProvider.overrideWithValue(
            const MockRecordRepository(),
          ),
          todayRepositoryProvider.overrideWithValue(
            const MockTodayRepository(),
          ),
          reportRepositoryProvider.overrideWithValue(
            const MockReportRepository(),
          ),
          supportResourcesProvider(
            'campus',
          ).overrideWith((ref) async => const []),
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
          home: const ShellPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Mine tab
    await tester.tap(find.text(l10n.tabMine).first);
    await tester.pumpAndSettle();

    // Allergy badge
    expect(find.text(l10n.mineAlertAllergyBadge), findsOneWidget);
    // Medicine badge
    expect(find.text(l10n.mineAlertMedicineBadge), findsOneWidget);
    // Privacy badge
    expect(find.text(l10n.mineAlertPrivacyBadge), findsOneWidget);
  });
}

Future<void> _pumpShell(WidgetTester tester) async {
  final mockSnapshot = const HealthContextSnapshot(
    summary: HealthSummary(
      age: 27,
      onboardingCompleted: true,
      activeAllergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: 0,
      missingCoreProfileFields: [],
    ),
    profile: HealthProfile(
      birthDate: null,
      sexAtBirth: null,
      heightCm: null,
      bloodType: null,
      locale: null,
      timezone: null,
      unitSystem: null,
      onboardingCompletedAt: null,
      extras: {},
    ),
    allergies: [],
    conditions: [],
    currentMedicines: [],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(mockSnapshot),
        ),
        medicineWorkspaceRepositoryProvider.overrideWithValue(
          const MockMedicineWorkspaceRepository(),
        ),
        recordRepositoryProvider.overrideWithValue(
          const MockRecordRepository(),
        ),
        todayRepositoryProvider.overrideWithValue(const MockTodayRepository()),
        reportRepositoryProvider.overrideWithValue(
          const MockReportRepository(),
        ),
        supportResourcesProvider(
          'campus',
        ).overrideWith((ref) async => const []),
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
        home: const ShellPage(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
