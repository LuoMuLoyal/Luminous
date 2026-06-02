import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
