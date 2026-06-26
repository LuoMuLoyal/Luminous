import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password_page.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Forgot password page sends reset code', (tester) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRemoteDataSourceProvider.overrideWithValue(remote)],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/forgot-password',
            routes: [
              GoRoute(
                path: '/forgot-password',
                builder: (context, state) => const ForgotPasswordPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(EditableText).first,
      'reset@example.com',
    );
    await tester.tap(find.text('发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.forgotPasswordEmail, 'reset@example.com');
  });

  testWidgets('Forgot password page submits reset request', (tester) async {
    final remote = FakeAuthRemoteDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRemoteDataSourceProvider.overrideWithValue(remote)],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/forgot-password',
            routes: [
              GoRoute(
                path: '/forgot-password',
                builder: (context, state) => const ForgotPasswordPage(),
              ),
            ],
          ),
        ),
      ),
    );

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'reset@example.com');
    await tester.enterText(inputs.at(1), '654321');
    await tester.enterText(inputs.at(2), 'Password123');
    await tester.enterText(inputs.at(3), 'Password123');
    final submitButton = find.widgetWithText(FilledButton, '重置密码');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(remote.resetPasswordEmail, 'reset@example.com');
    expect(remote.resetPasswordCode, '654321');
    expect(remote.resetPasswordValue, 'Password123');
    await tester.pump(const Duration(seconds: 2));
  });
}
