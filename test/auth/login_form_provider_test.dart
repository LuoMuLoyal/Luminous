import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/datasources/wechat_desktop_oauth_callback_listener.dart';
import 'package:luminous/features/auth/data/datasources/wechat_desktop_oauth_callback_server.dart';
import 'package:luminous/features/auth/data/datasources/wechat_mobile_auth_client.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/presentation/providers/auth_account_provider.dart';
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

  test(
    'startWechatIdentityLink completes mobile SDK identity linking',
    () async {
      final remote = FakeAuthRemoteDataSource();
      final mobileClient = _FakeWechatMobileAuthClient(
        code: 'mobile-link-code',
      );
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          wechatMobileAuthClientProvider.overrideWithValue(mobileClient),
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(authAccountProvider.notifier)
          .startWechatIdentityLink();

      expect(result, WechatIdentityLinkResult.completed);
      expect(mobileClient.authorizeCalled, isTrue);
      expect(remote.wechatMobileIdentityLinkCallbackCode, 'mobile-link-code');
      expect(
        container
            .read(authSessionProvider)
            .user
            ?.linkedIdentities
            .single
            .provider,
        'wechat_mobile',
      );
    },
  );

  test('startWechatIdentityLink completes desktop identity linking', () async {
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
        wechatMobileAuthClientProvider.overrideWithValue(
          _UnsupportedWechatMobileAuthClient(),
        ),
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final linkFuture = container
        .read(authAccountProvider.notifier)
        .startWechatIdentityLink();
    await Future<void>.delayed(Duration.zero);
    callbackCompleter.complete(
      const WechatOAuthCallback(
        code: 'wechat-link-code',
        state: 'link-state-1',
      ),
    );
    final result = await linkFuture;

    expect(result, WechatIdentityLinkResult.completed);
    expect(remote.createWechatIdentityLinkAuthorizeCalled, isTrue);
    expect(
      remote.wechatIdentityLinkAuthorizeCallbackUri,
      'http://127.0.0.1:49152/oauth/wechat',
    );
    expect(
      launcher.openedUri.toString(),
      'https://open.weixin.qq.com/connect/qrconnect?state=link-state-1',
    );
    expect(remote.wechatIdentityLinkCallbackCode, 'wechat-link-code');
    expect(remote.wechatIdentityLinkCallbackState, 'link-state-1');
    expect(isCallbackServerClosed, isTrue);
    expect(
      container
          .read(authSessionProvider)
          .user
          ?.linkedIdentities
          .single
          .provider,
      'wechat_web',
    );
  });

  test(
    'startWechatIdentityLink ignores mismatched desktop callback state',
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
          wechatMobileAuthClientProvider.overrideWithValue(
            _UnsupportedWechatMobileAuthClient(),
          ),
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final linkFuture = container
          .read(authAccountProvider.notifier)
          .startWechatIdentityLink();
      await Future<void>.delayed(Duration.zero);
      callbackCompleter.complete(
        const WechatOAuthCallback(
          code: 'wechat-link-code',
          state: 'wrong-state',
        ),
      );
      final result = await linkFuture;

      expect(result, WechatIdentityLinkResult.unsupported);
      expect(remote.wechatIdentityLinkCallbackCode, isNull);
      expect(remote.wechatIdentityLinkCallbackState, isNull);
      expect(isCallbackServerClosed, isTrue);
      expect(
        container.read(authSessionProvider).user?.linkedIdentities,
        isEmpty,
      );
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

class _UnsupportedWechatMobileAuthClient extends WechatMobileAuthClient {
  @override
  bool get isSupported => false;

  @override
  Future<String> authorize() {
    throw UnsupportedError('unsupported');
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
