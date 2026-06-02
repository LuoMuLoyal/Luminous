import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/presentation/pages/change_email_page.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Change email page sends verification code for change-email', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/change-email',
            routes: [
              GoRoute(
                path: '/account/change-email',
                builder: (context, state) => const ChangeEmailPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText).at(0), 'next@example.com');
    await tester.tap(find.text('发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.sentCodeEmail, 'next@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.changeEmail);
  });

  testWidgets('Change email page submits and updates session email', (
    tester,
  ) async {
    final remote = FakeAuthRemoteDataSource();
    final container = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(remote),
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/change-email',
            routes: [
              GoRoute(
                path: '/account/change-email',
                builder: (context, state) => const ChangeEmailPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText).at(0), 'next@example.com');
    await tester.enterText(find.byType(EditableText).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, '更新邮箱'));
    await tester.pump();

    expect(remote.changeEmailNewEmail, 'next@example.com');
    expect(remote.changeEmailCode, '123456');
    expect(container.read(authSessionProvider).user?.email, 'next@example.com');
    await tester.pump(const Duration(seconds: 2));
  });
}
