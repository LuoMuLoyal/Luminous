import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/presentation/pages/register_page.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Register page sends register verification code', (tester) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/register',
            routes: [
              GoRoute(
                path: '/register',
                builder: (context, state) => const RegisterPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(EditableText).first,
      'register@example.com',
    );
    await tester.tap(find.text('发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.sentCodeEmail, 'register@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.register);
  });

  testWidgets('Register page submits and applies session', (tester) async {
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
            initialLocation: '/register',
            routes: [
              GoRoute(
                path: '/register',
                builder: (context, state) => const RegisterPage(),
              ),
            ],
          ),
        ),
      ),
    );

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'register@example.com');
    await tester.enterText(inputs.at(1), '123456');
    await tester.enterText(inputs.at(2), 'Password123');
    await tester.enterText(inputs.at(3), 'Lumi');
    await tester.tap(find.widgetWithText(FilledButton, '创建账号'));
    await tester.pumpAndSettle();

    expect(remote.registerEmail, 'register@example.com');
    expect(remote.registerCode, '123456');
    expect(remote.registerPassword, 'Password123');
    expect(remote.registerNickname, 'Lumi');
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(
      container.read(authSessionProvider).user?.email,
      'register@example.com',
    );
  });
}
