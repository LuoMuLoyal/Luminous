import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';

void main() {
  testWidgets('AuthCodeFieldRow keeps input and button at the same height', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AuthCodeFieldRow(
                controller: controller,
                label: 'Code',
                buttonLabel: 'Send code',
                onSendCode: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final inputSize = tester.getSize(
      find.byKey(const ValueKey('auth-code-field-input')),
    );
    final buttonSize = tester.getSize(
      find.byKey(const ValueKey('auth-code-field-button')),
    );

    expect(inputSize.height, 56);
    expect(buttonSize.height, 56);
    expect(inputSize.height, buttonSize.height);
  });

  testWidgets('Auth code loading does not make submit button spin', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthCodeFieldRow(
                    controller: controller,
                    label: 'Code',
                    buttonLabel: 'Send code',
                    isLoading: true,
                    onSendCode: () {},
                  ),
                  const SizedBox(height: 12),
                  AuthPrimaryButton(
                    label: 'Submit',
                    isLoading: false,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('AuthTextField password field toggles visibility', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AuthTextField(
                controller: controller,
                label: 'Password',
                obscureText: true,
                prefix: const Icon(Icons.lock_outline),
              ),
            ),
          ),
        ),
      ),
    );

    // 初始: 密码被遮蔽,显示 visibility 图标。
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

    // 点击切换。
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    // 切换后: 密码可见,显示 visibility_off 图标。
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });

  testWidgets('AuthBrandLogo renders asset image', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: AuthBrandLogo())),
      ),
    );

    // Logo 容器存在; 图片资源在测试环境可能加载失败,但 errorBuilder 保证不崩溃。
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthShell renders logo and subtitle when provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AuthShell(
            title: 'Sign in',
            subtitle: 'My subtitle',
            logo: const AuthBrandLogo(),
            enableFormAnimation: false,
            form: const Column(children: [Text('form body')]),
          ),
        ),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('My subtitle'), findsOneWidget);
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });
}
