import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/datasources/wechat_mobile_auth_client.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Login page submits password login and updates session', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();
    final container = ProviderContainer(
      overrides: [authRemoteDataSourceProvider.overrideWithValue(remote)],
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
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
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
    final remote = FakeAuthRemoteDataSource();
    final container = ProviderContainer(
      overrides: [authRemoteDataSourceProvider.overrideWithValue(remote)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/login?returnTo=/settings',
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    LoginPage(returnTo: state.uri.queryParameters['returnTo']),
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
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(remote.loginEmail, 'user@example.com');
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(find.text('settings-page'), findsOneWidget);
  });

  testWidgets('Login page sends code in code mode', (tester) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRemoteDataSourceProvider.overrideWithValue(remote)],
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

  testWidgets('Login page opens WeChat authorize URL', (tester) async {
    final remote = FakeAuthRemoteDataSource();
    final launcher = _FakeExternalUrlLauncher();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
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

    await tester.tap(find.byKey(const Key('wechat-login-start-button')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(remote.createWechatAuthorizeCalled, isTrue);
    expect(
      launcher.openedUri.toString(),
      'https://open.weixin.qq.com/connect/qrconnect?state=state-1',
    );
    expect(find.byKey(const Key('wechat-callback-input')), findsOneWidget);
  });

  testWidgets('Login page uses mobile WeChat SDK before browser OAuth', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();
    final launcher = _FakeExternalUrlLauncher();
    final mobileClient = _FakeWechatMobileAuthClient(code: 'mobile-code');
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
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

    await tester.tap(find.byKey(const Key('wechat-login-start-button')));
    await tester.pumpAndSettle();

    expect(mobileClient.authorizeCalled, isTrue);
    expect(remote.wechatMobileCallbackCode, 'mobile-code');
    expect(remote.createWechatAuthorizeCalled, isFalse);
    expect(launcher.openedUri, isNull);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
  });

  testWidgets('Login page completes WeChat callback login', (tester) async {
    final remote = FakeAuthRemoteDataSource();
    final launcher = _FakeExternalUrlLauncher();
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
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

    await tester.tap(find.byKey(const Key('wechat-login-start-button')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.enterText(
      find.byKey(const Key('wechat-callback-input')),
      'https://app.example.com/oauth/wechat/callback?code=wechat-code&state=state-1',
    );
    final completeButton = find.widgetWithText(FilledButton, '完成微信登录');
    await tester.ensureVisible(completeButton);
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(remote.wechatCallbackCode, 'wechat-code');
    expect(remote.wechatCallbackState, 'state-1');
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(container.read(authSessionProvider).user?.nickname, 'WechatUser');
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
