import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/health_context/data/providers/data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/pages/page.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:luminous/features/mine/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/mine/data/repositories/mock_repository.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/completeness_notice.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/notification/presentation/providers/providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('Mine page renders mobile north-star sections', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpMinePage(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.tabMine), findsOneWidget);
    expect(find.text(l10n.mineAccountDisplayName), findsOneWidget);
    expect(find.text(l10n.mineCompletionTitle), findsOneWidget);
    expect(find.text(l10n.mineProfileTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsAccountTitle), findsOneWidget);

    final keys = <String>[
      'mine-account-header',
      'mine-archive-section',
      'mine-account-privacy-section',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key)).first;
      await tester.ensureVisible(finder);
      await tester.pump(const Duration(milliseconds: 200));
      expect(finder, findsOneWidget);
    }

    expect(find.byKey(const Key('mine-campus-surface')), findsNothing);
    expect(find.byKey(const Key('mine-status-overview')), findsNothing);
    expect(find.byKey(const Key('mine-privacy-section')), findsNothing);
    expect(find.byKey(const Key('mine-reminder-section')), findsNothing);
    expect(find.byKey(const Key('mine-settings-section')), findsNothing);
    expect(find.text(l10n.minePrivacyReportTitle), findsNothing);
    expect(find.text(l10n.mineReminderSectionTitle), findsNothing);
    expect(find.text(l10n.mineAccountSettingsTitle), findsNothing);
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
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => throw Exception('should not fetch when signed out'),
          ),
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
        ],
        child: const TestForuiApp(home: MinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.mineReadinessPreviewTitle), findsOneWidget);
    expect(find.text(l10n.mineAccountGuestDisplayName), findsOneWidget);
    expect(find.text(l10n.authGoLogin), findsOneWidget);
    expect(find.byType(SignInHintBanner), findsNothing);
    expect(find.text(l10n.mineErrorTitle), findsNothing);
    expect(find.byKey(const Key('mine-status-overview')), findsNothing);

    final basicSubtitle = find.text(l10n.mineArchiveBasicSubtitle);
    await tester.ensureVisible(basicSubtitle);
    await tester.pump();
    expect(basicSubtitle, findsOneWidget);
    expect(find.text(l10n.mineProfileMeta('--', '--')), findsNothing);
  });

  testWidgets('Mine loading shows dedicated skeleton placeholder', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final pending = Completer<MineDashboard>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _EmailSignedInAuthSessionNotifier(),
          ),
          mineDashboardProvider.overrideWith((ref) => pending.future),
          notificationUnreadCountProvider.overrideWith((ref) => 0),
        ],
        child: const TestForuiApp(home: MinePage()),
      ),
    );

    await tester.pump();

    expect(find.text(l10n.tabMine), findsOneWidget);
    expect(find.byType(MineSkeletonView), findsOneWidget);
    expect(find.byType(AppInlineSkeletonBlock), findsWidgets);

    expect(find.byKey(const Key('mine-privacy-section')), findsNothing);
    expect(find.byKey(const Key('mine-reminder-section')), findsNothing);
    expect(find.byKey(const Key('mine-settings-section')), findsNothing);
  });

  testWidgets('Mine settings action routes to settings page', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => _EmailSignedInAuthSessionNotifier(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(_mockSnapshot),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (context, state) => const MinePage()),
              GoRoute(
                path: '/settings',
                builder: (context, state) =>
                    const Scaffold(body: Text('settings-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('mine-settings-action')));
    await tester.pumpAndSettle();

    expect(find.text('settings-page'), findsOneWidget);
  });

  testWidgets('Mine account header routes to account page', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => _EmailSignedInAuthSessionNotifier(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(_mockSnapshot),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (context, state) => const MinePage()),
              GoRoute(
                path: '/account',
                builder: (context, state) =>
                    const Scaffold(body: Text('account-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text(l10n.mineAccountStudentRole), findsOneWidget);

    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await tester.pumpAndSettle();

    expect(find.text('account-page'), findsOneWidget);
  });

  testWidgets('Mine archive routes basic info to edit page', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => _EmailSignedInAuthSessionNotifier(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(_mockSnapshot),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (context, state) => const MinePage()),
              GoRoute(
                path: '/mine/profile/edit',
                builder: (context, state) => const ProfileEditPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final basicInfo = find.descendant(
      of: find.byKey(const Key('mine-archive-section')),
      matching: find.text(l10n.mineArchiveBasicTitle),
    );
    await tester.ensureVisible(basicInfo);
    await tester.tap(basicInfo);
    await tester.pumpAndSettle();

    expect(find.text(l10n.mineEditProfileTitle), findsOneWidget);
  });

  testWidgets('Mine archive shows login dialog when signed out', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(() => _SignedOutAuthSessionNotifier()),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => throw Exception('should not fetch when signed out'),
        ),
        mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (context, state) => const MinePage()),
              GoRoute(
                path: '/mine/profile/edit',
                builder: (context, state) => const ProfileEditPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => Scaffold(
                  body: Text(
                    "login-page:${state.uri.queryParameters['returnTo']}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final basicInfo = find.descendant(
      of: find.byKey(const Key('mine-archive-section')),
      matching: find.text(l10n.mineArchiveBasicTitle),
    );
    await tester.ensureVisible(basicInfo);
    await tester.tap(basicInfo);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MinePage), findsOneWidget);
    expect(find.byType(ProfileEditPage), findsNothing);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);
    expect(find.text('login-page:/'), findsNothing);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
    expect(find.byType(MinePage), findsOneWidget);
    expect(find.byType(ProfileEditPage), findsNothing);

    await tester.tap(basicInfo);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('login-page:/'), findsOneWidget);
    expect(find.byType(ProfileEditPage), findsNothing);
  });

  test('Mine dashboard uses auth and health-context data', () async {
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => _EmailSignedInAuthSessionNotifier(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(_mockSnapshot),
        ),
      ],
    );
    addTearDown(container.dispose);

    final dashboard = await container.read(mineDashboardProvider.future);

    expect(dashboard.account.email, 'user@example.com');
    expect(dashboard.account.emailVerified, isTrue);
    expect(dashboard.account.hasPassword, isTrue);
    expect(dashboard.account.linkedIdentityCount, 1);
    expect(dashboard.profile.age, 27);
    expect(dashboard.profile.allergyCount, 2);
    expect(dashboard.profile.currentMedicineCount, 3);
    expect(dashboard.completion.percentLabel, '80%');
    expect(
      dashboard.account.lastLoginAt,
      DateTime.parse('2026-01-02T08:30:00Z'),
    );
  });

  testWidgets('Mine completeness notice shows gaps when profile incomplete', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpMinePage(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MineCompletenessNotice), findsNothing);
    expect(find.text(l10n.mineCompletenessGapAction), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('mine-account-header')),
        matching: find.text(l10n.mineCompletenessGapBasicInfo),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Mine completeness notice hidden when profile complete', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _EmailSignedInAuthSessionNotifier(),
          ),
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(_completeSnapshot),
          ),
          notificationUnreadCountProvider.overrideWith((ref) => 0),
        ],
        child: const TestForuiApp(home: MinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.mineCompletenessGapTitle), findsNothing);
    expect(find.text(l10n.mineCompletenessGapAction), findsNothing);
    expect(find.text(l10n.mineReadinessManageAction), findsOneWidget);
  });

  testWidgets('Mine completeness notice hidden when signed out', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => throw Exception('should not fetch when signed out'),
          ),
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
        ],
        child: const TestForuiApp(home: MinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.mineCompletenessGapTitle), findsNothing);
    expect(find.byType(MineCompletenessNotice), findsNothing);
  });

  testWidgets('Mine page does not render campus services section', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _EmailSignedInAuthSessionNotifier(),
          ),
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(_mockSnapshot),
          ),
        ],
        child: const TestForuiApp(home: MinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('mine-campus-section')), findsNothing);
    expect(find.byKey(const Key('mine-campus-surface')), findsNothing);
  });
  testWidgets('Mine error state shows AppStateErrorView with retry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          mineDashboardProvider.overrideWith(
            (ref) => Future<MineDashboard>.error(Exception('test error')),
          ),
        ],
        child: const TestForuiApp(home: MinePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppStateErrorView), findsOneWidget);
    expect(find.text(l10n.mineErrorTitle), findsOneWidget);
    expect(find.text(l10n.mineErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('Mine page desktop layout uses desktop scroll key', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpMinePage(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Desktop layout uses a PageStorageKey for scroll position
    expect(
      find.byKey(const PageStorageKey<String>('mine-desktop-scroll')),
      findsOneWidget,
    );
    // Core sections still visible on desktop
    expect(find.text(l10n.mineAccountDisplayName), findsOneWidget);
  });
}

Future<void> _pumpMinePage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(_mockSnapshot),
        ),
        notificationUnreadCountProvider.overrideWith((ref) => 0),
      ],
      child: const TestForuiApp(home: MinePage()),
    ),
  );
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: true, isLoading: false);
  }
}

class _EmailSignedInAuthSessionNotifier extends AuthSessionNotifier {
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
        hasPassword: true,
        lastLoginAt: DateTime.parse('2026-01-02T08:30:00Z'),
        linkedIdentities: [
          AuthLinkedIdentity(
            id: 'identity-1',
            provider: 'wechat_web',
            email: null,
            emailVerifiedAt: null,
            linkedAt: DateTime.parse('2026-01-02T00:00:00Z'),
          ),
        ],
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

final _mockSnapshot = const HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 2,
    conditionCount: 1,
    currentMedicineCount: 3,
    missingCoreProfileFields: ['bloodType'],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: null,
    heightCm: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

final _completeSnapshot = const HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 2,
    conditionCount: 1,
    currentMedicineCount: 3,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: null,
    heightCm: 170.0,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
