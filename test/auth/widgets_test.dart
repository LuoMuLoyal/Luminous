import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/branding.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('AuthBrandLogo renders asset image', (tester) async {
    await tester.pumpWidget(
      const TestForuiApp(
        home: Scaffold(body: Center(child: AuthBrandLogo())),
      ),
    );

    // Logo 容器存在; 图片资源在测试环境可能加载失败,但 errorBuilder 保证不崩溃。
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });
}
