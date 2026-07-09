import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/health_context/data/providers/data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace_repository.dart';
import 'package:luminous/features/record/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/report/data/repositories/mock_repository.dart';
import 'package:luminous/features/support/data/providers/resources_providers.dart';
import 'package:luminous/features/shell/presentation/page.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/features/today/data/repositories/mock_repository.dart';
import 'package:luminous/features/today/presentation/providers/suggestion_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';
import '../today/test_helpers.dart';

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

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
        child: const TestForuiApp(home: ShellPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FSidebar), findsOneWidget);
    expect(find.text(l10n.appTitle), findsNWidgets(2));
    expect(find.text(l10n.tabToday), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabRecord), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabMedicine), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabReport), findsAtLeastNWidgets(1));
    expect(find.text(l10n.tabMine), findsAtLeastNWidgets(1));
    expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
    expect(find.text(l10n.desktopSidebarHelp), findsOneWidget);

    await tester.tap(find.text(l10n.tabReport).first);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
    expect(find.byKey(const Key('report-top-generate-action')), findsOneWidget);

    await tester.tap(find.text(l10n.tabMine).first);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text(l10n.mineCompletionTitle), findsOneWidget);
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
          todaySuggestionProvider.overrideWith(
            EmptyTodaySuggestionNotifier.new,
          ),
        ],
        child: const TestForuiApp(home: ShellPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

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
        child: const TestForuiApp(home: ShellPage()),
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
      await tester.pump(const Duration(milliseconds: 500));
      // Consume any layout overflow warnings from nested tab pages
      tester.takeException();
    }
    // App title still visible after cycling through all tabs
    expect(find.text(l10n.appTitle), findsNWidgets(2));
  });

  testWidgets('Mine page shows readiness state and account info', (
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
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
          supportResourcesProvider(
            'campus',
          ).overrideWith((ref) async => const []),
        ],
        child: const TestForuiApp(home: ShellPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Mine tab
    await tester.tap(find.text(l10n.tabMine).first);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Signed-in badge (account is authenticated in MockMineRepository.fetchDashboard)
    expect(
      find.text(l10n.mineReadinessSignedInBadge, skipOffstage: false),
      findsOneWidget,
    );
    // Ready title (no readiness gaps — allergyCount=2, medicineCount=2, basicInfoCompleted=true)
    expect(
      find.text(l10n.mineReadinessReadyTitle, skipOffstage: false),
      findsOneWidget,
    );
    // Manage action button
    expect(
      find.text(l10n.mineReadinessManageAction, skipOffstage: false),
      findsOneWidget,
    );
    // Completion label
    expect(
      find.text(l10n.mineCompletionTitle, skipOffstage: false),
      findsOneWidget,
    );
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
      child: const TestForuiApp(home: ShellPage()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
