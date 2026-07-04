import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_top_bar.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

void main() {
  group('AppTopBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_appShell(const AppTopBar(title: '今日')));

      expect(find.text('今日'), findsOneWidget);
    });

    testWidgets('title uses level8 display size', (tester) async {
      await tester.pumpWidget(_appShell(const AppTopBar(title: '今日')));

      final title = tester.widget<Text>(find.text('今日'));
      expect(title.style?.fontSize, equals(30));
    });

    testWidgets('renders trailing actions', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppTopBar(
            title: '今日',
            trailing: [
              IconButton(onPressed: () {}, icon: const Icon(FLucideIcons.bell)),
            ],
          ),
        ),
      );

      expect(find.byIcon(FLucideIcons.bell), findsOneWidget);
    });
  });
}
