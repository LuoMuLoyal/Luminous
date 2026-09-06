import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Forgot password page sends a verification code', (tester) async {
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(remote)],
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
    await tester.tap(find.widgetWithText(FButton, '发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.sentCodeEmail, 'reset@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.forgotPassword);
  });
}
