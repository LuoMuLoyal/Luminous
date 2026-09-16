import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/presentation/pages/login.dart';
import 'package:luminous/features/auth/presentation/pages/register.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Register page sends register verification code', (tester) async {
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(remote)],
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

  testWidgets('Register page submits and navigates to login', (tester) async {
    final remote = FakeLucentAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(remote)],
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
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginPage(),
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
    await tester.enterText(inputs.at(3), 'Password123');
    await tester.enterText(inputs.at(4), 'Lumi');
    final termsCheckbox = find.byType(FCheckbox);
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pumpAndSettle();
    final submitButton = find.widgetWithText(FButton, '创建账号');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    // Let the success toast timer fire.
    await tester.pump(const Duration(milliseconds: 2000));

    expect(remote.registerEmail, 'register@example.com');
    expect(remote.registerCode, '123456');
    expect(remote.registerPassword, 'Password123');
    expect(remote.registerNickname, 'Lumi');
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('terms checkbox announces the same text it renders', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(remote)],
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

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    // Semantics 默认不建树,需显式开启才能断言读屏标签。
    // 必须在测试体内 dispose:addTearDown 跑在框架的句柄校验之后。
    final handle = tester.ensureSemantics();
    await tester.pumpAndSettle();

    // 标签挂在 FCheckbox 内部的语义节点上,收集整棵子树里出现的所有 label。
    final labels = <String>[];
    void collect(SemanticsNode node) {
      if (node.label.isNotEmpty) labels.add(node.label);
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    collect(tester.getSemantics(find.byType(FCheckbox)));

    // 读屏标签由可见文案的同一批键拼装,而不是另写一句;这里锁住两者一致,
    // 避免将来只改可见文案、读屏仍念旧句。
    final joined = labels.join(' ');
    expect(joined, contains(l10n.authTermsAgreementPrefix));
    expect(joined, contains(l10n.authTermsOfService));
    expect(joined, contains(l10n.authPrivacyPolicy));
    expect(joined, contains(l10n.authTermsConjunction));

    handle.dispose();
  });
}
