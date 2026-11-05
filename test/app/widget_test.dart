import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/l10n/app_localizations.dart';
// `LuminousApp` builds `MaterialApp` from the standalone `material_ui` package
// (Flutter 3.47 split material out of the framework), so widget-type lookups
// must use the same library — a `Scrollbar` from `flutter/material.dart` is a
// different class.
import 'package:material_ui/material_ui.dart';

import '../helpers/kv_test_store.dart';

void main() {
  testWidgets('App restores auth session on startup', (tester) async {
    KvTestStore.install(seed: const <String, Object>{});

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
    KvTestStore.install(seed: const <String, Object>{});

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
    KvTestStore.install(seed: const <String, Object>{'app.locale': 'en'});

    const snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: null,
        onboardingCompleted: false,
        activeAllergyCount: 0,
        conditionCount: 0,
        currentMedicineCount: 0,
        missingCoreProfileFields: <String>[],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        weightKg: null,
        activityLevel: null,
        dietaryPreferences: null,
        locale: 'zh-CN',
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: <String, dynamic>{},
      ),
      allergies: <AllergyItem>[],
      conditions: <ConditionItem>[],
      currentMedicines: <CurrentMedicineItem>[],
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

    final preferences = KvStore.instance;
    expect(preferences.getOrNull<String>('app.locale'), 'zh-CN');
  });

  // 鸿蒙壳（ArkWeb）在 Flutter web 的 OS 探测里就是 `TargetPlatform.linux`：
  // ArkWeb 的 `navigator.platform` 以 "Linux" 开头、UA 里没有 "Android"
  // （`ui_web/browser_detection.dart`）。下面两个用例用同一个平台判定，
  // 断言「桌面滚动条」只由窗口尺寸决定是否绘制。
  //
  // `debugDefaultTargetPlatformOverride` 必须在测试体结束前复位：
  // 框架在测试体内断言 foundation 的调试变量已清空，`addTearDown` 太晚。
  Future<void> pumpAppAt(
    WidgetTester tester,
    Size size, {
    required TargetPlatform platform,
  }) async {
    KvTestStore.install(seed: const <String, Object>{});
    debugDefaultTargetPlatformOverride = platform;

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _NoopRestoreAuthSessionNotifier(),
          ),
        ],
        child: LuminousApp(routerConfig: _scrollRouter),
      ),
    );
    await tester.pump();
  }

  testWidgets('phone-sized surface gets no desktop scrollbar', (tester) async {
    try {
      // 手机短边 ≈ 426dp：桌面平台判定下仍不画常驻滚动条（鸿蒙壳回归）。
      await pumpAppAt(
        tester,
        const Size(426, 944),
        platform: TargetPlatform.linux,
      );

      expect(find.byType(Scrollbar), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('desktop-sized surface keeps the desktop scrollbar', (
    tester,
  ) async {
    try {
      await pumpAppAt(
        tester,
        const Size(1000, 700),
        platform: TargetPlatform.linux,
      );

      expect(find.byType(Scrollbar), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
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

/// A scrollable route so `ScrollBehavior.buildScrollbar` actually runs.
final _scrollRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, index) => ListTile(title: Text('row-$index')),
        ),
      ),
    ),
  ],
);
