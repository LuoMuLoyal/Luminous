import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/presentation/pages/change_email.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';

import 'test_helpers.dart';

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
    await tester.tap(find.widgetWithText(FButton, '更新邮箱'));
    await tester.pumpAndSettle();

    expect(remote.changeEmailNewEmail, 'next@example.com');
    expect(remote.changeEmailCode, '123456');
    expect(container.read(authSessionProvider).user?.email, 'next@example.com');
    await tester.pump(const Duration(seconds: 2));
  });
}
