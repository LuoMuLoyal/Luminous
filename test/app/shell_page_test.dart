import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/auth_test_helpers.dart';

void main() {
  testWidgets('Shell page uses five desktop tabs plus settings/help actions', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final mockSnapshot = HealthContextSnapshot(
      summary: const HealthSummary(
        age: 27,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 1,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: const HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        pregnancyState: null,
        lactationState: null,
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: const [],
      conditions: const [],
      currentMedicines: const [],
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
          supportResourcesProvider('campus').overrideWith((ref) async => const []),
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
}
