import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/pages/mine_page.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
    expect(find.text(l10n.mineAlertAllergyTitle), findsWidgets);
    expect(find.text(l10n.mineProfileTitle), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    final keys = <String>[
      'mine-account-header',
      'mine-status-overview',
      'mine-archive-section',
      'mine-campus-section',
      'mine-privacy-notice',
    ];

    for (final key in keys) {
      final finder = find.byKey(Key(key));
      await tester.scrollUntilVisible(finder, 260, scrollable: scrollable);
      await tester.pump(const Duration(milliseconds: 200));
      expect(finder, findsOneWidget);
    }

    expect(find.text(l10n.mineCampusSectionTitle), findsOneWidget);
    expect(find.byKey(const Key('mine-campus-surface')), findsOneWidget);
    expect(find.byType(IntrinsicHeight), findsNothing);
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
        ],
        child: _materialApp(const MinePage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(l10n.mineSignedOutNoticeTitle), findsOneWidget);
    expect(find.text(l10n.mineAccountGuestDisplayName), findsOneWidget);
    expect(find.text(l10n.authGoLogin), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.text(l10n.mineErrorTitle), findsNothing);

    final basicSubtitle = find.text(l10n.mineArchiveBasicSubtitle);
    await tester.scrollUntilVisible(
      basicSubtitle,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(basicSubtitle, findsOneWidget);
    expect(find.text(l10n.mineProfileMeta('--', '--')), findsNothing);
  });

  testWidgets(
    'Mine loading keeps static sections visible with skeleton slots',
    (tester) async {
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
          child: _materialApp(const MinePage()),
        ),
      );

      await tester.pump();

      expect(find.text(l10n.tabMine), findsOneWidget);
      expect(find.byType(AppInlineSkeletonBlock), findsWidgets);

      final scrollable = find.byType(Scrollable).first;
      for (final finder in [
        find.text(l10n.mineCampusSectionTitle),
        find.byKey(const Key('mine-privacy-notice')),
      ]) {
        await tester.scrollUntilVisible(finder, 260, scrollable: scrollable);
        await tester.pump();
        expect(finder, findsOneWidget);
      }

      expect(find.byKey(const Key('mine-privacy-section')), findsNothing);
      expect(find.byKey(const Key('mine-reminder-section')), findsNothing);
      expect(find.byKey(const Key('mine-settings-section')), findsNothing);
    },
  );

  testWidgets('Mine settings action routes to settings page', (tester) async {
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
        child: _routerApp([
          GoRoute(path: '/', builder: (context, state) => const MinePage()),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Text('settings-page')),
          ),
        ]),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byTooltip(l10n.mineHeaderSettings));
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
        child: _routerApp([
          GoRoute(path: '/', builder: (context, state) => const MinePage()),
          GoRoute(
            path: '/account',
            builder: (context, state) =>
                const Scaffold(body: Text('account-page')),
          ),
        ]),
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
        child: _routerApp([
          GoRoute(path: '/', builder: (context, state) => const MinePage()),
          GoRoute(
            path: '/mine/profile/edit',
            builder: (context, state) => const ProfileEditPage(),
          ),
        ]),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final basicInfo = find.text(l10n.mineArchiveBasicTitle);
    await tester.scrollUntilVisible(
      basicInfo,
      240,
      scrollable: find.byType(Scrollable).first,
    );
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
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _routerApp([
          GoRoute(path: '/', builder: (context, state) => const MinePage()),
          GoRoute(
            path: '/mine/profile/edit',
            builder: (context, state) => const ProfileEditPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => Scaffold(
              body: Text("login-page:${state.uri.queryParameters['returnTo']}"),
            ),
          ),
        ]),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final basicInfo = find.text(l10n.mineArchiveBasicTitle);
    await tester.scrollUntilVisible(
      basicInfo,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(basicInfo);
    await tester.pumpAndSettle();

    expect(find.byType(MinePage), findsOneWidget);
    expect(find.byType(ProfileEditPage), findsNothing);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);
    expect(find.text('login-page:/'), findsNothing);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
    expect(find.byType(MinePage), findsOneWidget);
    expect(find.byType(ProfileEditPage), findsNothing);

    await tester.tap(basicInfo);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await tester.pumpAndSettle();

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
        supportResourcesProvider(
          'campus',
        ).overrideWith((ref) async => const []),
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

  testWidgets(
    'Mine campus services stay visible but inactive without targets',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              () => _EmailSignedInAuthSessionNotifier(),
            ),
            healthContextSnapshotProvider.overrideWith(
              (ref) => Future.value(_mockSnapshot),
            ),
            supportResourcesProvider('campus').overrideWith(
              (ref) async => [
                SupportResourceDto(
                  id: 'campus-hospital',
                  scope: SupportResourceScope.campus,
                  title: 'Campus Hospital',
                  titleKey: null,
                  subtitle: 'On-campus medical services',
                  subtitleKey: null,
                  icon: 'local_hospital',
                  actionUrl: null,
                  actionType: null,
                  available: false,
                ),
              ],
            ),
          ],
          child: _materialApp(const MinePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.mineCampusSectionTitle), findsOneWidget);
      expect(find.text('Campus Hospital'), findsOneWidget);

      final campusRow = find.ancestor(
        of: find.text('Campus Hospital'),
        matching: find.byType(InkWell),
      );
      expect(campusRow, findsOneWidget);
      expect(tester.widget<InkWell>(campusRow).onTap, isNull);
    },
  );
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
      child: _materialApp(const MinePage()),
    ),
  );
}

Widget _materialApp(Widget home) {
  return MaterialApp(
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
    home: home,
  );
}

Widget _routerApp(List<RouteBase> routes) {
  return MaterialApp.router(
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
    routerConfig: GoRouter(initialLocation: '/', routes: routes),
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

final _mockSnapshot = HealthContextSnapshot(
  summary: const HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 2,
    conditionCount: 1,
    currentMedicineCount: 3,
    missingCoreProfileFields: ['bloodType'],
  ),
  profile: const HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: null,
    heightCm: null,
    pregnancyState: null,
    lactationState: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: {},
  ),
  allergies: const [],
  conditions: const [],
  currentMedicines: const [],
);
