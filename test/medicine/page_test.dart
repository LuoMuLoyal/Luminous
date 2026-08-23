import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart' show MedicineDoseLogsApi;
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/database.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/core/design/spacing.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/medicine/presentation/pages/page.dart';
import 'package:luminous/features/medicine/presentation/pages/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/safety_tips.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/red_flag.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/workspace_view.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/feature_mocks.dart';
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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

    // safety-summary no longer uses FCard (DecoratedBox instead);
    // only check the remaining sections.
    for (final key in <String>[
      'medicine-current-medications',
      'medicine-today-plan',
      'medicine-action-hub',
    ]) {
      expect(
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(FCard)),
        findsAtLeastNWidgets(1),
      );
    }
    expect(find.text(l10n.medicineTodayPlanTitle), findsOneWidget);
    expect(find.text(l10n.medicineSafetyPanelTitle), findsOneWidget);
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();

    expect(find.text(l10n.tabMedicine), findsOneWidget);
    expect(find.text(l10n.medicineHomeSearchHint), findsOneWidget);
    expect(find.byType(MedicineSkeletonView), findsOneWidget);
    expect(find.byType(InlineSkeletonBlock), findsWidgets);
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const _StaticMedicineWorkspaceRepository(_completedWorkspace),
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

  testWidgets(
    'Medicine all-overdue pending slot shows no-pending-dose empty state',
    (tester) async {
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
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
            medicineWorkspaceRepositoryProvider.overrideWithValue(
              const _StaticMedicineWorkspaceRepository(_allOverdueWorkspace),
            ),
          ],
          child: const TestForuiApp(home: MedicinePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final strip = find.byKey(const Key('medicine-next-reminder'));
      expect(strip, findsOneWidget);
      expect(
        find.descendant(
          of: strip,
          matching: find.text(l10n.medicineNoPendingDose),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: strip,
          matching: find.text(l10n.medicineScheduleNotSet),
        ),
        findsNothing,
      );
    },
  );

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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
          medicineRiskCheckRecordsProvider.overrideWith(
            (ref) async => MedicineRiskCheckRecords(
              staticRecord: MedicineRiskCheckRecord(
                checkType: MedicineRiskCheckType.static_,
                result: _riskResult,
                riskScore: 15,
                riskLevel: MedicineRiskLevel.caution,
                stale: false,
                createdAt: DateTime(2026, 7, 27, 10, 0),
                updatedAt: DateTime(2026, 7, 27, 10, 0),
              ),
            ),
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
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
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
      await tester.pumpAndSettle();
      await tester.tap(riskRow);
      await tester.pumpAndSettle();

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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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

  testWidgets('Medicine quick operations show scan and photo entries', (
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final hub = find.byKey(const Key('medicine-action-hub'));
    await tester.scrollUntilVisible(
      hub,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.medicineQuickActionBarcodeTitle), findsOneWidget);
    expect(find.text(l10n.medicineQuickActionBarcodeSubtitle), findsOneWidget);
    expect(find.text(l10n.medicineQuickActionCameraTitle), findsOneWidget);
    expect(find.text(l10n.medicineQuickActionCameraSubtitle), findsOneWidget);
  });

  testWidgets('Medicine scan quick action pushes the barcode scanner', (
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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
                path: Routes.scanBarcode,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('barcode-stub-page')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final barcodeRow = find.text(l10n.medicineQuickActionBarcodeTitle);
    await tester.scrollUntilVisible(
      barcodeRow,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(barcodeRow);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('barcode-stub-page'), findsOneWidget);
  });

  testWidgets('Medicine photo quick action opens the method picker sheet', (
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final cameraRow = find.text(l10n.medicineQuickActionCameraTitle);
    await tester.scrollUntilVisible(
      cameraRow,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cameraRow);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.scanMethodPickerTitle), findsOneWidget);
    expect(find.text(l10n.scanMethodOcrTitle), findsOneWidget);
    expect(find.text(l10n.scanMethodAiTitle), findsOneWidget);
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            _StaticMedicineWorkspaceRepository(_coverageGapWorkspace),
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
    // safe risk level → SemanticColor.success.solid
    expect(icon.color, SemanticColor.success.solid(context));
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

      const severeAllergyAlert = RedFlagAlert(
        rule: RedFlagRule.severeAllergy,
        primaryMedicineName: '阿莫西林',
        relatedLabel: '青霉素',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
            medicineRiskCheckRecordsProvider.overrideWith(
              (ref) async => MedicineRiskCheckRecords(
                staticRecord: MedicineRiskCheckRecord(
                  checkType: MedicineRiskCheckType.static_,
                  result: const MedicineRiskCheckResult(
                    currentMedicineCount: 2,
                    checkedMedicineCount: 1,
                    findings: [],
                    coverageIssues: [],
                    redFlags: [severeAllergyAlert],
                  ),
                  riskScore: 40,
                  riskLevel: MedicineRiskLevel.danger,
                  stale: false,
                  createdAt: DateTime(2026, 7, 27, 10, 0),
                  updatedAt: DateTime(2026, 7, 27, 10, 0),
                ),
              ),
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
          of: find.byType(RiskRedFlagSection),
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
      );

      final alerts = medicineAlertsFromRiskCheck(l10n, result);

      expect(alerts, hasLength(2));
      expect(
        alerts.any((alert) => (alert.rawTitle ?? '').contains('手动录入药品')),
        isTrue,
      );
    },
  );

  testWidgets('Medicine safety summary renders derived alert chips', (
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            _StaticMedicineWorkspaceRepository(_alertsWorkspace),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final safetySection = find.byKey(const Key('medicine-safety-summary'));
    await tester.scrollUntilVisible(
      safetySection,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.descendant(
        of: safetySection,
        matching: find.text(l10n.medicineRiskCheckFindingTitleInteraction),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: safetySection,
        matching: find.text(l10n.medicineRiskCheckFindingTitleAllergy),
      ),
      findsOneWidget,
    );
    // 2 findings + 1 coverage = 3 条告警，仅前 2 条为芯片，溢出显示 +1。
    expect(
      find.descendant(of: safetySection, matching: find.text('+1')),
      findsOneWidget,
    );
  });

  testWidgets('Medicine safety summary shows empty card without risk record', (
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const _StaticMedicineWorkspaceRepository(_completedWorkspace),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final safetySection = find.byKey(const Key('medicine-safety-summary'));
    await tester.scrollUntilVisible(
      safetySection,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.medicineSafetyPanelEmptyTitle), findsOneWidget);
    expect(find.text(l10n.medicineRiskCheckAllClearAlertTitle), findsNothing);
  });

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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
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

  testWidgets('Medicine search bar icon is offset by Spacing.level2', (
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
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
        child: const TestForuiApp(home: MedicinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final row = tester.widget<Row>(
      find
          .descendant(
            of: find.byKey(const Key('medicine-home-search-bar')),
            matching: find.byType(Row),
          )
          .first,
    );

    expect(row.children.first, isA<SizedBox>());
    expect((row.children.first as SizedBox).width, Spacing.level2);
    expect(row.children[1], isA<Icon>());
  });

  testWidgets(
    'Medicine signed-out preview with empty plan shows full dashboard empty states',
    (tester) async {
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
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
            medicineWorkspaceRepositoryProvider.overrideWithValue(
              const _EmptyPreviewWorkspaceRepository(),
            ),
          ],
          child: const TestForuiApp(home: MedicinePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SignInHintBanner), findsOneWidget);
      expect(find.text(l10n.medicineEmptyAddFirstTitle), findsNothing);

      for (final key in <String>[
        'medicine-current-medications',
        'medicine-today-plan',
        'medicine-safety-summary',
        'medicine-action-hub',
      ]) {
        final finder = find.byKey(Key(key));
        await tester.scrollUntilVisible(
          finder,
          240,
          scrollable: _medicineMobileScrollable(),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(finder, findsOneWidget);
      }

      expect(find.text(l10n.medicineNoMedicineTitle), findsOneWidget);
      expect(find.text(l10n.medicineTodayPlanEmpty), findsOneWidget);
      expect(find.text(l10n.medicineSafetyPanelEmptyTitle), findsOneWidget);
    },
  );

  testWidgets(
    'Medicine signed-in empty workspace keeps add-first empty state',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      const emptyWorkspace = MedicineWorkspace(
        hero: MedicineHero(
          metricDosesToday: '0',
          metricAdherence: '--',
          metricNextDose: '--',
        ),
        quickActions: <MedicineQuickAction>[],
        plan: MedicinePlanSurface(items: <MedicinePlanItem>[]),
        alerts: <MedicineAlert>[],
        promisePoints: <MedicinePromisePoint>[],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            notificationUnreadCountProvider.overrideWith((ref) async => 0),
            medicineWorkspaceRepositoryProvider.overrideWithValue(
              const _StaticMedicineWorkspaceRepository(emptyWorkspace),
            ),
          ],
          child: const TestForuiApp(home: MedicinePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.medicineEmptyAddFirstTitle), findsOneWidget);
      expect(find.byType(SignInHintBanner), findsNothing);
    },
  );

  testWidgets('home dose check-in marks taken and shows undo action', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = await _pumpDoseMarkPage(tester, db: db);

    final button = find.byKey(const Key('medicine-plan-dose-action-taken'));
    await tester.scrollUntilVisible(
      button,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(fake.markCalls, hasLength(1));
    expect(fake.markCalls.single.currentMedicineId, 'med-1');
    expect(fake.markCalls.single.reminderId, 'rem-1');
    expect(fake.markCalls.single.scheduledTime, '08:00');
    expect(fake.markCalls.single.status, 'taken');
    expect(find.text(l10n.medicineDoseActionSavedToast), findsOneWidget);
    expect(find.text(l10n.medicineDoseUndoAction), findsOneWidget);

    // Drain the toast auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  });

  testWidgets('home dose check-in undo reverts to planned', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = await _pumpDoseMarkPage(tester, db: db);

    final button = find.byKey(const Key('medicine-plan-dose-action-taken'));
    await tester.scrollUntilVisible(
      button,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.medicineDoseUndoAction), findsOneWidget);
    await tester.tap(find.text(l10n.medicineDoseUndoAction));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(fake.markCalls, hasLength(2));
    expect(fake.markCalls[1].currentMedicineId, 'med-1');
    expect(fake.markCalls[1].reminderId, 'rem-1');
    expect(fake.markCalls[1].scheduledTime, '08:00');
    expect(fake.markCalls[1].status, 'planned');
    expect(find.text(l10n.medicineDoseUndoneToast), findsOneWidget);

    // Drain the toast auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  });

  testWidgets('home dose check-in mark failure shows failed toast', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = await _pumpDoseMarkPage(tester, db: db);
    fake.markShouldFail = true;

    final button = find.byKey(const Key('medicine-plan-dose-action-taken'));
    await tester.scrollUntilVisible(
      button,
      240,
      scrollable: _medicineMobileScrollable(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.medicineDoseActionFailedToast), findsOneWidget);

    // Drain the toast auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  });
}

class _EmptyPreviewWorkspaceRepository implements MedicineWorkspaceRepository {
  const _EmptyPreviewWorkspaceRepository();

  @override
  TaskEither<LucentFailure, MedicineWorkspace> fetchWorkspace() =>
      TaskEither.right(MedicineWorkspace.signedOut());

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(MedicineWorkspace.signedOut());
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
  TaskEither<LucentFailure, MedicineWorkspace> fetchWorkspace() =>
      TaskEither.right(workspace);

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

const _completedWorkspace = MedicineWorkspace(
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

// 单药单槽 08:00 已过时刻未确认 → slot pending + isOverdue、todayStatus pending；
// 用于验证 _nextDoseFor 不再把「槽位全 overdue」的药误判为下一剂。
const _allOverdueWorkspace = MedicineWorkspace(
  hero: MedicineHero(
    metricDosesToday: '1',
    metricAdherence: '0%',
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
        rawDosage: '500 mg',
        rawSchedule: 'Once daily',
        slots: <MedicineDoseSlot>[
          MedicineDoseSlot(
            rawTime: '08:00',
            scheduledTime: '08:00',
            statusKey: MedicineCopyKey.doseStatusPending,
            status: MedicineDoseStatus.pending,
            isOverdue: true,
          ),
        ],
        stateKey: MedicineCopyKey.doseStatusPending,
        stateColor: SemanticColor.warning,
        todayStatus: MedicineDoseStatus.pending,
        currentMedicineId: 'med-1',
      ),
    ],
  ),
  alerts: <MedicineAlert>[],
  promisePoints: <MedicinePromisePoint>[],
);

final _coverageGapWorkspace = MedicineWorkspace(
  hero: const MedicineHero(
    metricDosesToday: '3',
    metricAdherence: '--',
    metricNextDose: '20:00',
  ),
  quickActions: <MedicineQuickAction>[],
  plan: const MedicinePlanSurface(
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
  riskCheckRecords: MedicineRiskCheckRecords(
    staticRecord: MedicineRiskCheckRecord(
      checkType: MedicineRiskCheckType.static_,
      result: const MedicineRiskCheckResult(
        currentMedicineCount: 1,
        checkedMedicineCount: 0,
        findings: <MedicineRiskFinding>[],
        coverageIssues: <MedicineRiskCoverageIssue>[
          MedicineRiskCoverageIssue(
            medicineName: 'Metformin',
            reason: MedicineRiskCoverageReason.manualEntry,
          ),
        ],
      ),
      riskScore: 0,
      riskLevel: MedicineRiskLevel.safe,
      stale: false,
      createdAt: DateTime(2026, 7, 27, 10, 0),
      updatedAt: DateTime(2026, 7, 27, 10, 0),
    ),
  ),
);

// 2 findings (interaction high + allergy medium) + 1 coverage issue →
// medicineAlertsFromRiskCheck 派生 3 条告警，用于验证主页安全卡告警芯片。
final _alertsWorkspace = MedicineWorkspace(
  hero: const MedicineHero(
    metricDosesToday: '1',
    metricAdherence: '--',
    metricNextDose: '--',
  ),
  quickActions: <MedicineQuickAction>[],
  plan: const MedicinePlanSurface(
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
            rawTime: '08:00',
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
  riskCheckRecords: MedicineRiskCheckRecords(
    staticRecord: MedicineRiskCheckRecord(
      checkType: MedicineRiskCheckType.static_,
      result: const MedicineRiskCheckResult(
        currentMedicineCount: 2,
        checkedMedicineCount: 2,
        findings: <MedicineRiskFinding>[
          MedicineRiskFinding(
            type: MedicineRiskFindingType.interaction,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: '布洛芬',
            secondaryMedicineName: '华法林',
          ),
          MedicineRiskFinding(
            type: MedicineRiskFindingType.allergy,
            severity: MedicineRiskSeverity.medium,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: '阿莫西林',
            relatedLabel: '青霉素',
          ),
        ],
        coverageIssues: <MedicineRiskCoverageIssue>[
          MedicineRiskCoverageIssue(
            medicineName: '手动录入药品',
            reason: MedicineRiskCoverageReason.manualEntry,
          ),
        ],
      ),
      riskScore: 30,
      riskLevel: MedicineRiskLevel.risk,
      stale: false,
      createdAt: DateTime(2026, 7, 27, 10, 0),
      updatedAt: DateTime(2026, 7, 27, 10, 0),
    ),
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

// 单药单槽 08:00 pending（reminderId/scheduledTime 齐全），用于验证主页打卡
// mark 参数传递与撤销反向 mark(planned)。
const _singlePendingSlotWorkspace = MedicineWorkspace(
  hero: MedicineHero(
    metricDosesToday: '1',
    metricAdherence: '--',
    metricNextDose: '08:00',
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
        rawDosage: '500 mg',
        rawSchedule: 'Once daily',
        slots: <MedicineDoseSlot>[
          MedicineDoseSlot(
            reminderId: 'rem-1',
            scheduledTime: '08:00',
            rawTime: '08:00',
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
);

Future<_FakeCachedDoseLogDataSource> _pumpDoseMarkPage(
  WidgetTester tester, {
  required AppDatabase db,
}) async {
  final fake = _FakeCachedDoseLogDataSource(db: db);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        notificationUnreadCountProvider.overrideWith((ref) async => 0),
        medicineWorkspaceRepositoryProvider.overrideWithValue(
          const _StaticMedicineWorkspaceRepository(_singlePendingSlotWorkspace),
        ),
        cachedDoseLogDataSourceProvider.overrideWith((ref) => fake),
      ],
      child: const TestForuiApp(showToaster: true, home: MedicinePage()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  return fake;
}

class _FakeCachedDoseLogDataSource extends CachedDoseLogDataSource {
  _FakeCachedDoseLogDataSource({required AppDatabase db})
    : super(
        remote: DoseLogRemoteDataSource(
          api: MedicineDoseLogsApi(Dio()),
          dio: Dio(),
        ),
        dao: db.medicineDoseLogDao,
      );

  final markCalls = <_MarkCall>[];
  bool markShouldFail = false;

  @override
  TaskEither<LucentFailure, DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) {
    markCalls.add(
      _MarkCall(
        currentMedicineId: currentMedicineId,
        status: status,
        date: date,
        reminderId: reminderId,
        scheduledTime: scheduledTime,
      ),
    );
    if (markShouldFail) {
      return TaskEither.left(LucentFailure.unknown(message: 'mark failed'));
    }
    return TaskEither.right(
      DoseLogItem(
        id: 'marked-${markCalls.length}',
        currentMedicineId: currentMedicineId,
        reminderId: reminderId,
        status: DoseLogStatus.taken,
        scheduledFor: date,
        scheduledTime: scheduledTime,
        createdAt: '2026-07-10T00:00:00.000Z',
        updatedAt: '2026-07-10T00:00:00.000Z',
      ),
    );
  }
}

class _MarkCall {
  const _MarkCall({
    required this.currentMedicineId,
    required this.status,
    required this.date,
    this.reminderId,
    this.scheduledTime,
  });

  final String currentMedicineId;
  final String status;
  final String date;
  final String? reminderId;
  final String? scheduledTime;
}

Finder _medicineMobileScrollable() {
  return find
      .descendant(
        of: find.byKey(const PageStorageKey<String>('medicine-mobile-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
}
