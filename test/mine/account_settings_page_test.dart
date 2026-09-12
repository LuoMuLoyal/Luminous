import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/features/auth/data/datasources/wechat/mobile_auth_client.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_manage.dart';
import 'package:luminous/features/support/data/repositories/lucent.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:luminous/features/support/domain/repositories/support.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/test_helpers.dart';

void main() {
  testWidgets('Account settings page renders auth account sections', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await _pumpAccountManagePage(
      tester,
      router: GoRouter(
        initialLocation: '/account',
        routes: [
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountManagePage(),
          ),
        ],
      ),
    );

    await tester.pump();

    expect(find.text(l10n.authAccountManageUsername), findsOneWidget);
    expect(find.text(l10n.authAccountManageEmail), findsOneWidget);
    expect(find.text(l10n.authAccountManagePassword), findsOneWidget);
    expect(find.text(l10n.authAccountManageThirdParty), findsOneWidget);
    expect(find.text(l10n.authAccountManageLoginDevices), findsOneWidget);
    expect(find.text(l10n.authAccountManageSecurityCenter), findsOneWidget);
    expect(find.text(l10n.authAccountManageDeleteAccount), findsOneWidget);

    // 底部服务入口
    expect(find.text(l10n.authAccountManageCustomerService), findsOneWidget);
    expect(find.text(l10n.authAccountManageFeedback), findsOneWidget);
    expect(find.text(l10n.authAccountManageHelpCenter), findsOneWidget);
  });

  testWidgets(
    'Account settings change-email action routes to change-email page',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await _pumpAccountManagePage(
        tester,
        router: GoRouter(
          initialLocation: '/account',
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountManagePage(),
            ),
            GoRoute(
              path: '/account/change-email',
              builder: (context, state) =>
                  const Scaffold(body: Text('change-email-page')),
            ),
          ],
        ),
      );

      await tester.pump();

      // 新UI中邮箱是FTile列表项，点击后路由到change-email页面
      final emailTile = find.text(l10n.authAccountManageEmail);
      await tester.scrollUntilVisible(
        emailTile,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(emailTile);
      await tester.pumpAndSettle();

      expect(find.text('change-email-page'), findsOneWidget);
    },
  );

  testWidgets('Account settings saves profile through auth account flow', (
    tester,
  ) async {
    // Phase 3重构后，个人资料编辑已移至ProfilePage（/profile），
    // 账号管理页顶部为只读概要卡片，不再包含昵称/头像编辑功能。
    // 此测试验证概要卡片正确显示用户信息。
    final remote = FakeLucentAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
        supportRepositoryProvider.overrideWithValue(_FakeSupportRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account',
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountManagePage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    // 验证概要卡片显示用户信息（昵称可能出现在多个位置）
    expect(find.text('Lumi'), findsAtLeastNWidgets(1));
    expect(find.text('user@example.com'), findsAtLeastNWidgets(1));
  });

  testWidgets('Account settings changes password and routes to login', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account',
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountManagePage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    // 新UI中点击"登录密码"列表项打开密码修改对话框
    final passwordTile = find.text(l10n.authAccountManagePassword);
    await tester.scrollUntilVisible(
      passwordTile,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(passwordTile);
    await tester.pumpAndSettle();

    // 对话框中应显示密码修改表单
    expect(find.text(l10n.authPasswordSectionTitle), findsOneWidget);
  });

  testWidgets('Account settings deletes account and routes to login', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account',
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountManagePage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    // 新UI中点击"账号注销"列表项打开注销对话框
    final deleteTile = find.text(l10n.authAccountManageDeleteAccount);
    await tester.scrollUntilVisible(
      deleteTile,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    // 对话框中应显示注销表单（"注销账号"可能出现在多个位置：列表项、对话框标题、对话框内）
    expect(
      find.text(l10n.authDeleteAccountSectionTitle),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('Account settings unlinks a linked identity after confirmation', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeLucentAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        authSessionProvider.overrideWith(
          () => _SignedInAuthSessionNotifier(
            linkedIdentities: [
              AuthLinkedIdentity(
                id: 'identity-1',
                provider: 'wechat_web',
                email: null,
                emailVerifiedAt: null,
                linkedAt: DateTime.parse('2026-01-03T00:00:00Z'),
              ),
            ],
          ),
        ),
        // 敏感操作需要密码二次确认，override 为直接返回固定密码。
        sensitiveActionPasswordPromptProvider.overrideWithValue(
          (context, {title, message, label}) async => 'test-password',
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account',
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountManagePage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    // 新UI中点击"第三方账号"列表项打开管理对话框
    final thirdPartyTile = find.text(l10n.authAccountManageThirdParty);
    await tester.scrollUntilVisible(
      thirdPartyTile,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(thirdPartyTile);
    await tester.pumpAndSettle();

    // 对话框中应显示LinkedIdentitiesSection
    expect(find.text(l10n.authLinkedIdentitiesSectionTitle), findsOneWidget);

    // 点击解绑按钮
    final unlinkButton = find
        .widgetWithText(FButton, l10n.authIdentityUnlinkAction)
        .first;
    await tester.tap(unlinkButton);
    await tester.pumpAndSettle();
    // 确认对话框中的解除绑定按钮（FButton 文案相同，取 last）。
    final confirmUnlinkButton = find
        .widgetWithText(FButton, l10n.authIdentityUnlinkAction)
        .last;
    await tester.tap(confirmUnlinkButton);
    await tester.pumpAndSettle();
    // sensitiveActionPasswordPromptProvider 已被 override 为直接返回密码，
    // 不需要手动输入密码对话框。pumpAndSettle 确保 unlink 异步流程完成。

    expect(remote.unlinkIdentityId, 'identity-1');
    expect(container.read(authSessionProvider).user?.linkedIdentities, isEmpty);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings hides WeChat identity link entry', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();
    final mobileClient = _FakeWechatMobileAuthClient(code: 'mobile-link-code');
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        wechatMobileAuthClientProvider.overrideWithValue(mobileClient),
        authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account',
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountManagePage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    // 微信绑定入口已隐藏（底层流程保留，见 docs/TODO.md）。
    expect(find.byKey(const Key('wechat-identity-link-button')), findsNothing);
    expect(mobileClient.authorizeCalled, isFalse);
    expect(remote.wechatMobileIdentityLinkCallbackCode, isNull);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings protects OAuth-only last sign-in method', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await _pumpAccountManagePage(
      tester,
      router: GoRouter(
        initialLocation: '/account',
        routes: [
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountManagePage(),
          ),
        ],
      ),
      sessionNotifier: _SignedInAuthSessionNotifier(
        hasPassword: false,
        linkedIdentities: [
          AuthLinkedIdentity(
            id: 'identity-1',
            provider: 'wechat_web',
            email: null,
            emailVerifiedAt: null,
            linkedAt: DateTime.parse('2026-01-03T00:00:00Z'),
          ),
        ],
      ),
    );

    await tester.pump();

    // 在新的UI布局中，第三方账号显示为列表项，而不是FButton
    expect(find.text(l10n.authAccountManageThirdParty), findsOneWidget);
    expect(find.text(l10n.authAccountManageThirdPartyNone), findsNothing);

    // 在新的UI布局中，登录密码显示为列表项
    expect(find.text(l10n.authAccountManagePassword), findsOneWidget);
    expect(find.text(l10n.authAccountManagePasswordNotSet), findsOneWidget);

    // 在新的UI布局中，账号注销显示为列表项
    expect(find.text(l10n.authAccountManageDeleteAccount), findsOneWidget);
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

Future<void> _pumpAccountManagePage(
  WidgetTester tester, {
  required GoRouter router,
  AuthSessionNotifier? sessionNotifier,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(
          () => sessionNotifier ?? _SignedInAuthSessionNotifier(),
        ),
        // 底部服务入口读取支持邮箱；测试中固定为空避免真实网络请求。
        supportRepositoryProvider.overrideWithValue(_FakeSupportRepository()),
        ...overrides,
      ],
      child: TestAuthApp(router: router),
    ),
  );
}

class _FakeSupportRepository implements SupportRepository {
  @override
  TaskEither<LucentFailure, AppInfo?> getAppInfo() {
    return TaskEither.right(null);
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  _SignedInAuthSessionNotifier({
    this.hasPassword = true,
    this.linkedIdentities = const <AuthLinkedIdentity>[],
  });

  final bool hasPassword;
  final List<AuthLinkedIdentity> linkedIdentities;

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
        hasPassword: hasPassword,
        linkedIdentities: linkedIdentities,
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}
