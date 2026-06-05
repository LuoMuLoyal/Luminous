import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/datasources/wechat_desktop_oauth_callback_listener.dart';
import 'package:luminous/features/auth/data/datasources/wechat_desktop_oauth_callback_server.dart';
import 'package:luminous/features/auth/data/datasources/wechat_mobile_auth_client.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/providers/login_form_provider.dart';

import 'auth_test_helpers.dart';

void main() {
  test('startWechatMobileLogin completes SDK callback login', () async {
    final remote = FakeAuthRemoteDataSource();
    final mobileClient = _FakeWechatMobileAuthClient(code: 'mobile-code');
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
        wechatMobileAuthClientProvider.overrideWithValue(mobileClient),
      ],
    );
    addTearDown(container.dispose);

    final session = await container
        .read(loginFormProvider.notifier)
        .startWechatMobileLogin();

    expect(session, isNotNull);
    expect(mobileClient.authorizeCalled, isTrue);
    expect(remote.wechatMobileCallbackCode, 'mobile-code');
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(container.read(authSessionProvider).user?.nickname, 'WxMobile');
  });

  test('startWechatDesktopWebLogin completes desktop callback login', () async {
    final remote = FakeAuthRemoteDataSource();
    final launcher = _FakeExternalUrlLauncher();
    final callbackCompleter = Completer<WechatOAuthCallback>();
    var isCallbackServerClosed = false;
    final callbackServer = WechatDesktopOAuthCallbackServer(
      callbackUri: Uri.parse('http://127.0.0.1:49152/oauth/wechat'),
      callback: callbackCompleter.future,
      close: () async {
        isCallbackServerClosed = true;
      },
    );
    final listener = _FakeWechatDesktopOAuthCallbackListener(callbackServer);
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
        externalUrlLauncherProvider.overrideWithValue(launcher),
        wechatDesktopOAuthCallbackListenerProvider.overrideWithValue(listener),
      ],
    );
    addTearDown(container.dispose);

    final loginFuture = container
        .read(loginFormProvider.notifier)
        .startWechatDesktopWebLogin();
    await Future<void>.delayed(Duration.zero);
    callbackCompleter.complete(
      const WechatOAuthCallback(code: 'wechat-code', state: 'state-1'),
    );
    final session = await loginFuture;

    expect(session, isNotNull);
    expect(remote.createWechatAuthorizeCalled, isTrue);
    expect(
      remote.wechatAuthorizeCallbackUri,
      'http://127.0.0.1:49152/oauth/wechat',
    );
    expect(
      launcher.openedUri.toString(),
      'https://open.weixin.qq.com/connect/qrconnect?state=state-1',
    );
    expect(remote.wechatCallbackCode, 'wechat-code');
    expect(remote.wechatCallbackState, 'state-1');
    expect(isCallbackServerClosed, isTrue);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
  });

  test(
    'startWechatDesktopWebLogin ignores mismatched callback state',
    () async {
      final remote = FakeAuthRemoteDataSource();
      final launcher = _FakeExternalUrlLauncher();
      final callbackCompleter = Completer<WechatOAuthCallback>();
      var isCallbackServerClosed = false;
      final callbackServer = WechatDesktopOAuthCallbackServer(
        callbackUri: Uri.parse('http://127.0.0.1:49152/oauth/wechat'),
        callback: callbackCompleter.future,
        close: () async {
          isCallbackServerClosed = true;
        },
      );
      final listener = _FakeWechatDesktopOAuthCallbackListener(callbackServer);
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          externalUrlLauncherProvider.overrideWithValue(launcher),
          wechatDesktopOAuthCallbackListenerProvider.overrideWithValue(
            listener,
          ),
        ],
      );
      addTearDown(container.dispose);

      final loginFuture = container
          .read(loginFormProvider.notifier)
          .startWechatDesktopWebLogin();
      await Future<void>.delayed(Duration.zero);
      callbackCompleter.complete(
        const WechatOAuthCallback(code: 'wechat-code', state: 'wrong-state'),
      );
      final session = await loginFuture;

      expect(session, isNull);
      expect(remote.wechatCallbackCode, isNull);
      expect(remote.wechatCallbackState, isNull);
      expect(isCallbackServerClosed, isTrue);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    },
  );
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

class _FakeWechatDesktopOAuthCallbackListener
    extends WechatDesktopOAuthCallbackListener {
  const _FakeWechatDesktopOAuthCallbackListener(this.server);

  final WechatDesktopOAuthCallbackServer server;

  @override
  bool get isSupported => true;

  @override
  Future<WechatDesktopOAuthCallbackServer> start() async => server;
}
