import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Login page submits password login and updates session', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
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

  testWidgets('Login page sends code in code mode', (tester) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
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

    await tester.tap(find.text('验证码'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'code@example.com');
    await tester.tap(find.text('发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.sentCodeEmail, 'code@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.login);
  });
}
