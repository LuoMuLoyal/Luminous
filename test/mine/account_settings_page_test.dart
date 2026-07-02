import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_mobile_auth_client.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/auth_test_helpers.dart';

void main() {
  testWidgets('Account settings page renders auth account sections', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await _pumpAccountSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/account',
        routes: [
          GoRoute(
            path: '/account',
            builder: (context, state) =>
                const AccountSettingsPage(enableFormAnimation: false),
          ),
        ],
      ),
    );

    await tester.pump();

    expect(find.text(l10n.authAccountOverviewTitle), findsAtLeastNWidgets(1));
    expect(find.text(l10n.authProfileSectionTitle), findsOneWidget);
    expect(find.text(l10n.authEmailSectionTitle), findsOneWidget);
    expect(find.text(l10n.authPasswordSectionTitle), findsOneWidget);

    await tester.tap(find.text(l10n.authPasswordSectionTitle));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authChangePasswordAction), findsOneWidget);
    expect(find.text(l10n.authDeleteAccountAction), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'Account settings change-email action routes to change-email page',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await _pumpAccountSettingsPage(
        tester,
        router: GoRouter(
          initialLocation: '/account',
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) =>
                  const AccountSettingsPage(enableFormAnimation: false),
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

      final changeEmailButton = find.widgetWithText(FButton, l10n.authEmailChangeAction);
      await tester.scrollUntilVisible(
        changeEmailButton,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(changeEmailButton);
      await tester.pumpAndSettle();

      expect(find.text('change-email-page'), findsOneWidget);
    },
  );

  testWidgets('Account settings saves profile through auth account flow', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
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
                builder: (context, state) =>
                    const AccountSettingsPage(enableFormAnimation: false),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText).at(0), 'NewNick');
    await tester.enterText(
      find.byType(EditableText).at(1),
      'https://example.com/avatar.png',
    );
    final saveProfileButton = find.widgetWithText(FButton, '保存资料');
    await tester.ensureVisible(saveProfileButton);
    await tester.tap(saveProfileButton);
    await tester.pumpAndSettle();

    expect(remote.updateProfileNickname, 'NewNick');
    expect(remote.updateProfileAvatar, 'https://example.com/avatar.png');
    expect(container.read(authSessionProvider).user?.nickname, 'NewNick');
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings changes password and routes to login', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
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
                builder: (context, state) =>
                    const AccountSettingsPage(enableFormAnimation: false),
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
    await tester.tap(find.text(l10n.authPasswordSectionTitle));
    await tester.pumpAndSettle();

    final passwordFields = find.byType(EditableText).hitTestable();
    final oldPasswordField = passwordFields.at(0);
    await tester.ensureVisible(oldPasswordField);
    await tester.enterText(oldPasswordField, 'old-password');
    await tester.enterText(passwordFields.at(1), 'new-password');
    final changePasswordButton = find.widgetWithText(FButton, l10n.authChangePasswordAction);
    await tester.ensureVisible(changePasswordButton);
    await tester.tap(changePasswordButton);
    await tester.pumpAndSettle();

    expect(remote.changePasswordOldPassword, 'old-password');
    expect(remote.changePasswordNewPassword, 'new-password');
    expect(find.text('login-page'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings deletes account and routes to login', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
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
                builder: (context, state) =>
                    const AccountSettingsPage(enableFormAnimation: false),
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
    await tester.tap(find.text(l10n.authPasswordSectionTitle));
    await tester.pumpAndSettle();

    final passwordFields = find.byType(EditableText).hitTestable();
    final deletePasswordField = passwordFields.last;
    await tester.ensureVisible(deletePasswordField);
    await tester.enterText(deletePasswordField, 'delete-password');
    final deleteButton = find.widgetWithText(FButton, l10n.authDeleteAccountAction);
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(remote.deleteAccountPassword, 'delete-password');
    expect(find.text('login-page'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings unlinks a linked identity after confirmation', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeAuthRemoteDataSource();
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
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
                builder: (context, state) =>
                    const AccountSettingsPage(enableFormAnimation: false),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    final unlinkButton = find.widgetWithText(FButton, l10n.authIdentityUnlinkAction).first;
    await tester.scrollUntilVisible(
      unlinkButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(unlinkButton);
    await tester.pumpAndSettle();
    final confirmUnlinkButton = find.widgetWithText(FButton, l10n.authIdentityUnlinkAction).last;
    await tester.tap(confirmUnlinkButton);
    await tester.pumpAndSettle();

    expect(remote.unlinkIdentityId, 'identity-1');
    expect(container.read(authSessionProvider).user?.linkedIdentities, isEmpty);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings links WeChat identity through account flow', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();
    final mobileClient = _FakeWechatMobileAuthClient(code: 'mobile-link-code');
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
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
                builder: (context, state) =>
                    const AccountSettingsPage(enableFormAnimation: false),
              ),
            ],
          ),
        ),
      ),
    );

    final linkButton = find.byKey(const Key('wechat-identity-link-button'));
    await tester.scrollUntilVisible(
      linkButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(linkButton);
    await tester.pumpAndSettle();

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
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings protects OAuth-only last sign-in method', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await _pumpAccountSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/account',
        routes: [
          GoRoute(
            path: '/account',
            builder: (context, state) =>
                const AccountSettingsPage(enableFormAnimation: false),
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

    expect(
      find.widgetWithText(FButton, l10n.authIdentityUnlinkDisabledAction),
      findsOneWidget,
    );

    await tester.tap(find.text(l10n.authPasswordSectionTitle));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authPasswordUnsetManagementHint), findsOneWidget);
    expect(
      find.text(l10n.authDeleteAccountPasswordRequiredHint),
      findsOneWidget,
    );
    expect(find.widgetWithText(FButton, l10n.authChangePasswordAction), findsNothing);
    expect(find.widgetWithText(FButton, l10n.authDeleteAccountAction), findsNothing);
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

Future<void> _pumpAccountSettingsPage(
  WidgetTester tester, {
  required GoRouter router,
  AuthSessionNotifier? sessionNotifier,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(
          () => sessionNotifier ?? _SignedInAuthSessionNotifier(),
        ),
      ],
      child: TestAuthApp(router: router),
    ),
  );
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
