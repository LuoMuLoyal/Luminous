import 'package:luminous/core/design/app_design.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_risk_check_page.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/medicine_skeleton_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/medicine_workspace_view.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_risk_check_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
          home: const MedicinePage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.tabMedicine), findsOneWidget);
    expect(find.text(l10n.medicineHomeSearchHint), findsOneWidget);
    expect(find.text(l10n.medicineDrugboxTitle), findsOneWidget);
    expect(find.text('Metformin'), findsAtLeastNWidgets(1));

    final scrollable = find.byType(Scrollable);
    final keys = <String>[
      'medicine-hero',
      'medicine-next-reminder',
      'medicine-safety-panel',
      'medicine-quick-actions',
      'medicine-today-plan',
      'medicine-safety-tips',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 300));
      expect(finder, findsOneWidget);
      if (key == 'medicine-quick-actions') {
        expect(find.text(l10n.medicineQuickSafetyCheckTitle), findsOneWidget);
        expect(find.text('用药报告'), findsNothing);
      }
    }

    for (final key in <String>[
      'medicine-safety-panel',
      'medicine-quick-actions',
      'medicine-safety-tips',
    ]) {
      expect(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(AppSectionSurface),
        ),
        findsOneWidget,
      );
    }
    expect(find.text(l10n.medicineSafetyTipsTitle), findsOneWidget);
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
          home: const MedicinePage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text(l10n.tabMedicine), findsOneWidget);
    expect(find.text(l10n.medicineHomeSearchHint), findsOneWidget);
    expect(find.byType(MedicineSkeletonView), findsOneWidget);
    expect(find.byType(AppInlineSkeletonBlock), findsWidgets);
    expect(find.text(l10n.medicineDrugboxTitle), findsNothing);
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
            const _StaticMedicineWorkspaceRepository(_completedWorkspace),
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
          home: const MedicinePage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.medicineNoPendingDose), findsOneWidget);
    expect(find.text(l10n.medicineNoPendingDoseDetail), findsOneWidget);
    expect(find.text(l10n.medicineDoseActionTaken), findsNothing);
    expect(find.text(l10n.medicineDoseActionSkipped), findsNothing);
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
        child: MaterialApp.router(
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final riskTitle = find.text('风险检查').first;
    await tester.ensureVisible(riskTitle);
    await tester.pumpAndSettle();
    final riskRow = find
        .ancestor(of: riskTitle, matching: find.byType(InkWell))
        .first;
    await tester.tap(riskRow);
    await tester.pumpAndSettle();

    expect(find.text('检查概览'), findsOneWidget);
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
          child: MaterialApp.router(
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

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final riskTitle = find.text('风险检查').first;
      await tester.ensureVisible(riskTitle);
      await tester.pumpAndSettle();
      final riskRow = find
          .ancestor(of: riskTitle, matching: find.byType(InkWell))
          .first;
      await tester.tap(riskRow);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    },
  );

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
          child: MaterialApp.router(
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
      expect(find.byType(TextButton), findsNothing);
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
          home: const MedicinePage(),
        ),
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
          home: const MedicinePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Desktop layout uses a PageStorageKey for scroll position
    expect(
      find.byKey(const PageStorageKey<String>('medicine-desktop-scroll')),
      findsOneWidget,
    );
  });
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
        color: AppColorTokens.cyanDeep,
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
        stateColor: AppColorTokens.warningDeep,
        todayStatus: MedicineDoseStatus.skipped,
        currentMedicineId: 'med-1',
      ),
    ],
  ),
  alerts: <MedicineAlert>[],
  promisePoints: <MedicinePromisePoint>[],
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
