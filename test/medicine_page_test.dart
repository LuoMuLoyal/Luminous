import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
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
    expect(find.text(l10n.medicineMockNameMetformin), findsAtLeastNWidgets(1));

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

    expect(find.text(l10n.medicineSafetyTipsTitle), findsOneWidget);
  });

  testWidgets(
    'Medicine loading keeps static chrome visible with skeleton slots',
    (tester) async {
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
      expect(find.text(l10n.medicineDrugboxTitle), findsOneWidget);
      expect(find.byType(AppInlineSkeletonBlock), findsWidgets);

      final quickOperationTitle = find.text(l10n.medicineQuickOperationTitle);
      await tester.scrollUntilVisible(
        quickOperationTitle,
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(quickOperationTitle, findsOneWidget);
    },
  );

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
        nameKey: MedicineCopyKey.mockNameMetformin,
        dosageKey: MedicineCopyKey.mockDoseMetformin,
        scheduleKey: MedicineCopyKey.mockScheduleDailyOnce,
        slots: <MedicineDoseSlot>[
          MedicineDoseSlot(
            timeKey: MedicineCopyKey.mockTime2000,
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
