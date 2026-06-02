import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Account settings page renders auth account sections', (
    tester,
  ) async {
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

    expect(find.text('账号与安全'), findsAtLeastNWidgets(1));
    expect(find.text('资料信息'), findsOneWidget);
    expect(find.text('登录邮箱'), findsOneWidget);
    expect(find.text('修改密码'), findsOneWidget);
    expect(find.text('注销账号'), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'Account settings change-email action routes to change-email page',
    (tester) async {
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

      final changeEmailButton = find.text('更换邮箱');
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
        child: MaterialApp.router(
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
          routerConfig: GoRouter(
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
    await tester.tap(find.widgetWithText(FilledButton, '保存资料'));
    await tester.pump();

    expect(remote.updateProfileNickname, 'NewNick');
    expect(remote.updateProfileAvatar, 'https://example.com/avatar.png');
    expect(container.read(authSessionProvider).user?.nickname, 'NewNick');
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings changes password and routes to login', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
        ],
        child: MaterialApp.router(
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
          routerConfig: GoRouter(
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

    final oldPasswordField = find.byType(EditableText).at(3);
    await tester.ensureVisible(oldPasswordField);
    await tester.enterText(oldPasswordField, 'old-password');
    await tester.enterText(find.byType(EditableText).at(4), 'new-password');
    final changePasswordButton = find.text('更新密码');
    await tester.ensureVisible(changePasswordButton);
    await tester.tap(find.widgetWithText(FilledButton, '更新密码'));
    await tester.pumpAndSettle();

    expect(remote.changePasswordOldPassword, 'old-password');
    expect(remote.changePasswordNewPassword, 'new-password');
    expect(find.text('login-page'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Account settings deletes account and routes to login', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
        ],
        child: MaterialApp.router(
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
          routerConfig: GoRouter(
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

    final deletePasswordField = find.byType(EditableText).at(5);
    await tester.ensureVisible(deletePasswordField);
    await tester.enterText(deletePasswordField, 'delete-password');
    final deleteButton = find.text('注销账号');
    await tester.ensureVisible(deleteButton.last);
    await tester.tap(find.widgetWithText(FilledButton, '注销账号'));
    await tester.pumpAndSettle();

    expect(remote.deleteAccountPassword, 'delete-password');
    expect(find.text('login-page'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}

Future<void> _pumpAccountSettingsPage(
  WidgetTester tester, {
  required GoRouter router,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
      ],
      child: MaterialApp.router(
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
        routerConfig: router,
      ),
    ),
  );
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
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
        emailVerified: true,
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}
