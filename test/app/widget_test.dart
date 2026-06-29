import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App restores auth session on startup', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    final notifier = _TrackingAuthSessionNotifier();
    final container = ProviderContainer(
      overrides: [authSessionProvider.overrideWith(() => notifier)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: LuminousApp(routerConfig: _testRouter),
      ),
    );

    await tester.pump();

    expect(notifier.restoreCalled, isTrue);
    expect(find.text('app-home'), findsOneWidget);
  });

  testWidgets('App should render', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _NoopRestoreAuthSessionNotifier(),
          ),
        ],
        child: LuminousApp(routerConfig: _testRouter),
      ),
    );
    await tester.pump();
    expect(find.text('app-home'), findsOneWidget);
  });

  testWidgets('App backfills locale from Lucent health-context profile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'app.locale': 'en',
    });

    final snapshot = HealthContextSnapshot(
      summary: const HealthSummary(
        age: null,
        onboardingCompleted: false,
        activeAllergyCount: 0,
        conditionCount: 0,
        currentMedicineCount: 0,
        missingCoreProfileFields: <String>[],
      ),
      profile: const HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        pregnancyState: null,
        lactationState: null,
        bloodType: null,
        locale: 'zh-CN',
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: <String, dynamic>{},
      ),
      allergies: const <AllergyItem>[],
      conditions: const <ConditionItem>[],
      currentMedicines: const <CurrentMedicineItem>[],
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => _RestoringSignedInAuthSessionNotifier(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(snapshot),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: LuminousApp(routerConfig: _localizedRouter),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app.locale'), 'zh-CN');
  });
}

class _TrackingAuthSessionNotifier extends AuthSessionNotifier {
  bool restoreCalled = false;

  @override
  Future<void> restore() async {
    restoreCalled = true;
  }
}

class _NoopRestoreAuthSessionNotifier extends AuthSessionNotifier {
  @override
  Future<void> restore() async {}
}

class _RestoringSignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  Future<void> restore() async {
    state = AuthSessionState(
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

final _testRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Text('app-home')),
    ),
  ],
);

final _localizedRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: Text(AppLocalizations.of(context)!.desktopSidebarSettings),
      ),
    ),
  ],
);
