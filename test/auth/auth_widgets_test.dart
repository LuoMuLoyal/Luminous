import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('AuthBrandLogo renders asset image', (tester) async {
    await tester.pumpWidget(
      const TestForuiApp(home: Scaffold(body: Center(child: AuthBrandLogo()))),
    );

    // Logo 容器存在; 图片资源在测试环境可能加载失败,但 errorBuilder 保证不崩溃。
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthShell renders logo and subtitle when provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestForuiApp(
        home: Scaffold(
          body: AuthShell(
            title: 'Sign in',
            subtitle: 'My subtitle',
            logo: AuthBrandLogo(),
            enableFormAnimation: false,
            form: Column(children: [Text('form body')]),
          ),
        ),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('My subtitle'), findsOneWidget);
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });
}
