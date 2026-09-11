import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/datasources/wechat/mobile_auth_client.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/presentation/pages/login.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Login page submits password login and updates session', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(remote)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText).at(0), 'user@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'Password123');
    await tester.tap(find.widgetWithText(FButton, '登录'));
    await tester.pumpAndSettle();

    expect(remote.loginEmail, 'user@example.com');
    expect(remote.loginPassword, 'Password123');
    expect(remote.loginCode, isNull);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(container.read(authSessionProvider).user?.email, 'user@example.com');
  });

  testWidgets('Login page returns to returnTo after password login', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(remote)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login?return-to=/settings',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    LoginPage(returnTo: state.uri.queryParameters['return-to']),
              ),
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

    await tester.enterText(find.byType(EditableText).at(0), 'user@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'Password123');
    await tester.tap(find.widgetWithText(FButton, '登录'));
    await tester.pumpAndSettle();

    expect(remote.loginEmail, 'user@example.com');
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(find.text('settings-page'), findsOneWidget);
  });

  testWidgets(
    'Login page leaves the login route after password login without returnTo',
    (tester) async {
      // Sign-out and the "go to login" links navigate to a bare `/login`
      // (no `return-to` query), so post-login navigation must not depend on
      // that hint being present.
      final remote = FakeLucentAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(remote)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestAuthApp(
            router: GoRouter(
              initialLocation: '/login',
              routes: [
                GoRoute(
                  path: '/login',
                  builder: (context, state) => const LoginPage(),
                ),
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: Text('home-page')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(EditableText).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(EditableText).at(1), 'Password123');
      await tester.tap(find.widgetWithText(FButton, '登录'));
      await tester.pumpAndSettle();

      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('home-page'), findsOneWidget);
    },
  );

  testWidgets('Login page sends code in code mode', (tester) async {
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(remote)],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('验证码'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'code@example.com');
    await tester.tap(find.text('发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.sentCodeEmail, 'code@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.login);
  });

  testWidgets('Login page hides WeChat and Weibo OAuth entries', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();
    final launcher = _FakeExternalUrlLauncher();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          externalUrlLauncherProvider.overrideWithValue(launcher),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // WeChat / Weibo UI 入口已隐藏（底层流程保留，见 docs/TODO.md）。
    expect(find.byKey(const Key('wechat-login-start-button')), findsNothing);
    expect(find.byKey(const Key('weibo-login-start-button')), findsNothing);
    // QQ / Google 入口仍显示。
    expect(find.byKey(const Key('qq-login-start-button')), findsOneWidget);
    expect(find.byKey(const Key('google-login-start-button')), findsOneWidget);
  });

  testWidgets('Login page uses mobile WeChat SDK before browser OAuth', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();
    final launcher = _FakeExternalUrlLauncher();
    final mobileClient = _FakeWechatMobileAuthClient(code: 'mobile-code');
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        externalUrlLauncherProvider.overrideWithValue(launcher),
        wechatMobileAuthClientProvider.overrideWithValue(mobileClient),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginPage(),
              ),
              GoRoute(path: '/', builder: (context, state) => const SizedBox()),
            ],
          ),
        ),
      ),
    );

    // 微信入口已隐藏，但底层流程仍可通过 provider 直接驱动；
    // 此处验证隐藏后桌面/移动 SDK 不因 UI 展示而触发。
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('wechat-login-start-button')), findsNothing);
    expect(mobileClient.authorizeCalled, isFalse);
    expect(remote.wechatMobileCallbackCode, isNull);
    expect(remote.createWechatAuthorizeCalled, isFalse);
    expect(launcher.openedUri, isNull);
  });

  testWidgets('Login page completes WeChat callback login', (tester) async {
    final remote = FakeLucentAuthRepository();
    final launcher = _FakeExternalUrlLauncher();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        externalUrlLauncherProvider.overrideWithValue(launcher),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginPage(),
              ),
              GoRoute(path: '/', builder: (context, state) => const SizedBox()),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 微信入口隐藏后,回调完成流程不再经由登录页 UI 触发;
    // 逻辑层覆盖见 login_form_provider_test.dart。
    expect(find.byKey(const Key('wechat-login-start-button')), findsNothing);
    expect(remote.wechatCallbackCode, isNull);
    expect(remote.wechatCallbackState, isNull);
  });
}

class _FakeWechatMobileAuthClient extends WechatMobileAuthClient {
  _FakeWechatMobileAuthClient({required this.code});

  final String code;
  bool authorizeCalled = false;

  @override
  bool get isSupported => true;

  @override
  Future<String> authorize() async {
    authorizeCalled = true;
    return code;
  }
}

class _FakeExternalUrlLauncher extends ExternalUrlLauncher {
  Uri? openedUri;

  @override
  Future<bool> open(Uri uri) async {
    openedUri = uri;
    return true;
  }
}
