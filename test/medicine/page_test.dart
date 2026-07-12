import 'package:luminous/core/design/semantic_color.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/medicine/presentation/pages/page.dart';
import 'package:luminous/features/medicine/presentation/pages/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_red_flag.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/workspace_view.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';
import 'package:luminous/features/medicine/presentation/providers/safety_tips.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('Medicine page renders mobile north-star sections', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.tabMedicine), findsOneWidget);
    expect(find.text(l10n.medicineHomeSearchHint), findsOneWidget);
    expect(find.text(l10n.medicineDrugboxTitle), findsOneWidget);
    expect(find.text('Metformin'), findsAtLeastNWidgets(1));

    final scrollable = _medicineMobileScrollable();
    final keys = <String>[
      'medicine-current-medications',
      'medicine-today-plan',
      'medicine-safety-summary',
      'medicine-action-hub',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 300));
      expect(finder, findsOneWidget);
      if (key == 'medicine-action-hub') {
        expect(find.text(l10n.medicineQuickSafetyCheckTitle), findsOneWidget);
        expect(find.text('用药报告'), findsNothing);
      }
    }

    for (final key in <String>[
      'medicine-current-medications',
      'medicine-today-plan',
      'medicine-safety-summary',
      'medicine-action-hub',
    ]) {
      expect(
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(FCard)),
        findsAtLeastNWidgets(1),
      );
    }
    expect(find.text(l10n.medicineTodayPlanTitle), findsOneWidget);
    expect(find.text(l10n.medicineSafetyPanelTitle), findsOneWidget);
    expect(find.text(l10n.medicineSafetyPanelSubtitle), findsOneWidget);
    expect(find.byKey(const Key('medicine-reference-notice')), findsNothing);
    expect(find.byKey(const Key('medicine-safety-tips')), findsNothing);
  });

  testWidgets('Medicine loading shows dedicated skeleton placeholder', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final pending = Completer<MedicineWorkspace>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicineWorkspaceProvider.overrideWith((ref) => pending.future),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();

    expect(find.text(l10n.tabMedicine), findsOneWidget);
    expect(find.text(l10n.medicineHomeSearchHint), findsOneWidget);
    expect(find.byType(MedicineSkeletonView), findsOneWidget);
    expect(find.byType(AppInlineSkeletonBlock), findsWidgets);
    expect(find.text(l10n.medicineDrugboxTitle), findsNothing);
  });

  testWidgets('Medicine search bar keeps a taller mobile touch target', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final size = tester.getSize(
      find.byKey(const Key('medicine-home-search-bar')),
    );
    expect(size.height, greaterThanOrEqualTo(56));
  });

  testWidgets('Medicine completed doses hide today dose action buttons', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            _StaticMedicineWorkspaceRepository(_completedWorkspace),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.medicineNoPendingDose), findsOneWidget);
    expect(find.text(l10n.medicineNoPendingDoseDetail), findsOneWidget);
    expect(
      find.byKey(const Key('medicine-next-dose-action-taken')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('medicine-next-dose-action-skipped')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('medicine-plan-dose-action-taken')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('medicine-plan-dose-action-skipped')),
      findsNothing,
    );
    expect(find.text(l10n.medicineDoseStatusSkipped), findsAtLeastNWidgets(1));
  });

  testWidgets('Medicine risk-check quick action navigates when signed in', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          medicineRiskCheckProvider.overrideWith((ref) async => _riskResult),
          redFlagAlertsProvider.overrideWith((ref) async => const []),
        ],
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const MedicinePage(),
              ),
              GoRoute(
                path: '/medicine/risk-check',
                builder: (context, state) => const MedicineRiskCheckPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login')),
              ),
            ],
          ),
        ),
      ),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final riskRow = find.text(l10n.medicineQuickSafetyCheckTitle);
    await tester.ensureVisible(riskRow);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(riskRow);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(l10n.medicineRiskCheckPageTitle), findsOneWidget);
  });

  testWidgets(
    'Medicine risk-check quick action prompts login when signed out',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedOutAuthSessionNotifier.new),
            medicineWorkspaceRepositoryProvider.overrideWithValue(
              const MockMedicineWorkspaceRepository(),
            ),
          ],
          child: TestForuiRouterApp(
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const MedicinePage(),
                ),
                GoRoute(
                  path: '/medicine/risk-check',
                  builder: (context, state) => const MedicineRiskCheckPage(),
                ),
                GoRoute(
                  path: '/login',
                  builder: (context, state) =>
                      const Scaffold(body: Text('login')),
                ),
              ],
            ),
          ),
        ),
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final riskRow = find.text(l10n.medicineQuickSafetyCheckTitle);
      await tester.ensureVisible(riskRow);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(riskRow);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    },
  );

  testWidgets('Medicine page keeps preview workspace when signed out', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedOutAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SignInHintBanner), findsOneWidget);
    expect(find.text(l10n.medicineEmptyAddFirstTitle), findsNothing);
    expect(find.text('Metformin'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
    expect(find.byKey(const Key('medicine-action-hub')), findsOneWidget);
  });

  testWidgets('Medicine uncovered safety summary uses readable icon color', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const _StaticMedicineWorkspaceRepository(_coverageGapWorkspace),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final icon = tester.widget<Icon>(
      find.byKey(const Key('medicine-safety-summary-icon')),
    );
    final context = tester.element(find.byType(MedicinePage));
    expect(icon.color, context.theme.colors.mutedForeground);
  });

  testWidgets(
    'Medicine risk-check page renders red-flag banner without campus resource button',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final severeAllergyAlert = const RedFlagAlert(
        rule: RedFlagRule.severeAllergy,
        primaryMedicineName: '阿莫西林',
        relatedLabel: '青霉素',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            medicineRiskCheckProvider.overrideWith((ref) async => _riskResult),
            redFlagAlertsProvider.overrideWith(
              (ref) async => [severeAllergyAlert],
            ),
          ],
          child: TestForuiRouterApp(
            routerConfig: GoRouter(
              initialLocation: '/medicine/risk-check',
              routes: [
                GoRoute(
                  path: '/medicine/risk-check',
                  builder: (context, state) => const MedicineRiskCheckPage(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Red-flag banner title visible
      expect(find.text('红旗警告'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MedicineRiskRedFlagBanner),
          matching: find.byType(FButton),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'workspace safety alerts keep coverage boundary when findings also exist',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 2,
        checkedMedicineCount: 1,
        findings: [
          MedicineRiskFinding(
            type: MedicineRiskFindingType.interaction,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: '布洛芬',
            secondaryMedicineName: '华法林',
          ),
        ],
        coverageIssues: [
          MedicineRiskCoverageIssue(
            medicineName: '手动录入药品',
            reason: MedicineRiskCoverageReason.manualEntry,
          ),
        ],
        coverageSummary: '还有 1 种药品缺少可检查资料。',
      );

      final alerts = medicineAlertsFromRiskCheck(l10n, result);

      expect(alerts, hasLength(2));
      expect(
        alerts.any((alert) => (alert.rawTitle ?? '').contains('缺少可检查资料')),
        isTrue,
      );
    },
  );

  testWidgets('Medicine error state shows MedicineErrorView with retry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceProvider.overrideWith(
            (ref) => Future<MedicineWorkspace>.error(Exception('test error')),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MedicineErrorView), findsOneWidget);
    expect(find.text(l10n.medicineErrorTitle), findsOneWidget);
    expect(find.text(l10n.medicineErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Medicine page desktop layout uses desktop scroll key', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          medicineSafetyTipListProvider.overrideWith(
            () => _EmptySafetyTipListNotifier(),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Desktop layout uses a PageStorageKey for scroll position
    expect(
      find.byKey(const PageStorageKey<String>('medicine-desktop-scroll')),
      findsOneWidget,
    );
  });
}

class _EmptySafetyTipListNotifier extends MedicineSafetyTipListNotifier {
  @override
  Future<List<MedicineSafetyTip>> build() async => const [];
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _StaticMedicineWorkspaceRepository
    implements MedicineWorkspaceRepository {
  const _StaticMedicineWorkspaceRepository(this.workspace);

  final MedicineWorkspace workspace;

  @override
  Future<MedicineWorkspace> fetchWorkspace() async => workspace;

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(MedicineWorkspace.signedOut());
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

final _completedWorkspace = const MedicineWorkspace(
  hero: MedicineHero(
    metricDosesToday: '1/1',
    metricAdherence: '100%',
    metricNextDose: '--',
  ),
  quickActions: <MedicineQuickAction>[],
  plan: MedicinePlanSurface(
    items: <MedicinePlanItem>[
      MedicinePlanItem(
        color: SemanticColor.primary,
        nameKey: MedicineCopyKey.genericName,
        dosageKey: MedicineCopyKey.genericDosage,
        scheduleKey: MedicineCopyKey.genericSchedule,
        rawName: 'Metformin',
        rawDosage: '0.5 g',
        rawSchedule: 'Once daily',
        slots: <MedicineDoseSlot>[
          MedicineDoseSlot(
            rawTime: '20:00',
            statusKey: MedicineCopyKey.doseStatusSkipped,
            status: MedicineDoseStatus.skipped,
          ),
        ],
        stateKey: MedicineCopyKey.doseStatusSkipped,
        stateColor: SemanticColor.primary,
        todayStatus: MedicineDoseStatus.skipped,
        currentMedicineId: 'med-1',
      ),
    ],
  ),
  alerts: <MedicineAlert>[],
  promisePoints: <MedicinePromisePoint>[],
);

const _coverageGapWorkspace = MedicineWorkspace(
  hero: MedicineHero(
    metricDosesToday: '3',
    metricAdherence: '--',
    metricNextDose: '20:00',
  ),
  quickActions: <MedicineQuickAction>[],
  plan: MedicinePlanSurface(
    items: <MedicinePlanItem>[
      MedicinePlanItem(
        color: SemanticColor.primary,
        nameKey: MedicineCopyKey.genericName,
        dosageKey: MedicineCopyKey.genericDosage,
        scheduleKey: MedicineCopyKey.genericSchedule,
        rawName: 'Metformin',
        rawDosage: '0.5 g',
        rawSchedule: 'Twice daily',
        slots: <MedicineDoseSlot>[
          MedicineDoseSlot(
            rawTime: '08:00',
            scheduledTime: '08:00',
            statusKey: MedicineCopyKey.doseStatusPending,
            status: MedicineDoseStatus.pending,
          ),
        ],
        stateKey: MedicineCopyKey.doseStatusPending,
        stateColor: SemanticColor.primary,
        todayStatus: MedicineDoseStatus.pending,
        currentMedicineId: 'med-1',
      ),
    ],
  ),
  alerts: <MedicineAlert>[],
  promisePoints: <MedicinePromisePoint>[],
  riskCheckResult: MedicineRiskCheckResult(
    currentMedicineCount: 1,
    checkedMedicineCount: 0,
    findings: <MedicineRiskFinding>[],
    coverageIssues: <MedicineRiskCoverageIssue>[
      MedicineRiskCoverageIssue(
        medicineName: 'Metformin',
        reason: MedicineRiskCoverageReason.manualEntry,
      ),
    ],
    coverageSummary: '以下药品缺少可检查资料，无法自动确认安全性。',
  ),
);

const _riskResult = MedicineRiskCheckResult(
  currentMedicineCount: 2,
  checkedMedicineCount: 1,
  findings: [
    MedicineRiskFinding(
      type: MedicineRiskFindingType.foodInteraction,
      severity: MedicineRiskSeverity.medium,
      context: MedicineRiskFindingContext.alcohol,
      primaryMedicineName: '布洛芬',
      evidence: 'Avoid alcohol while taking this medicine.',
    ),
  ],
  coverageIssues: [
    MedicineRiskCoverageIssue(
      medicineName: '手动录入药品',
      reason: MedicineRiskCoverageReason.manualEntry,
    ),
  ],
);

Finder _medicineMobileScrollable() {
  return find
      .descendant(
        of: find.byKey(const PageStorageKey<String>('medicine-mobile-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
}
