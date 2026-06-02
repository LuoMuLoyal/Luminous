import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Shell page uses five desktop tabs plus settings/help actions', (
    tester,
  ) async {
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
          home: const ShellPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Luminous'), findsOneWidget);
    expect(find.text('今日'), findsOneWidget);
    expect(find.text('记录'), findsAtLeastNWidgets(1));
    expect(find.text('用药'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('更多'), findsAtLeastNWidgets(1));
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('帮助'), findsOneWidget);

    await tester.tap(find.text('我的').first);
    await tester.pumpAndSettle();
    expect(find.text('我的'), findsAtLeastNWidgets(2));
    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);

    await tester.tap(find.text('更多').first);
    await tester.pumpAndSettle();
    expect(find.text('更多'), findsAtLeastNWidgets(2));
    expect(find.text('SOS 紧急求助'), findsOneWidget);
  });
}
