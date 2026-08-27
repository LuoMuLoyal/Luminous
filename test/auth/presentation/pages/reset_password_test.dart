import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/presentation/pages/reset_password.dart';

import '../../test_helpers.dart';

void main() {
  group('ResetPasswordPage — empty token guard', () {
    testWidgets('shows missing-token error state when token is empty', (
      tester,
    ) async {
      final remote = FakeLucentAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(remote)],
          child: TestAuthApp(
            router: GoRouter(
              initialLocation: '/reset-password',
              routes: [
                GoRoute(
                  path: '/reset-password',
                  builder: (context, state) =>
                      const ResetPasswordPage(token: ''),
                ),
                GoRoute(
                  path: '/forgot-password',
                  builder: (context, state) =>
                      const SizedBox(key: Key('forgot-password-page')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the missing-token title and message
      expect(find.text('重置链接无效'), findsOneWidget);
      expect(find.text('前往忘记密码'), findsOneWidget);
    });

    testWidgets('navigates to forgot-password when action is tapped', (
      tester,
    ) async {
      final remote = FakeLucentAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(remote)],
          child: TestAuthApp(
            router: GoRouter(
              initialLocation: '/reset-password',
              routes: [
                GoRoute(
                  path: '/reset-password',
                  builder: (context, state) =>
                      const ResetPasswordPage(token: ''),
                ),
                GoRoute(
                  path: '/forgot-password',
                  builder: (context, state) =>
                      const SizedBox(key: Key('forgot-password-page')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FButton, '前往忘记密码'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forgot-password-page')), findsOneWidget);
    });
  });
}
