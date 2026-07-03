import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

Widget _sectionLabel(String title) {
  return FHeader.nested(title: Text(title));
}

void main() {
  group('FBadge.raw — 图标徽章', () {
    testWidgets('FBadge.raw 渲染图标', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FBadge.raw(
            builder: (context, style) => const Icon(Icons.star, size: 16),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('FBadge.raw 渲染图标带自定义颜色', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FBadge.raw(
            builder: (context, style) => const Icon(Icons.favorite, size: 16),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('FHeader.nested — 段落标题', () {
    testWidgets('渲染标题文本', (tester) async {
      await tester.pumpWidget(_appShell(_sectionLabel('Settings')));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('支持前缀图标列表', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const FHeader.nested(
            title: Text('Profile'),
            prefixes: [Icon(Icons.person)],
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('支持后缀组件列表', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const FHeader.nested(
            title: Text('Actions'),
            suffixes: [Text('Edit')],
          ),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });
  });

  group('FTile — 文本操作行', () {
    testWidgets('渲染标签文本', (tester) async {
      await tester.pumpWidget(
        _appShell(FTile(title: const Text('View all'), onPress: null)),
      );

      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('默认显示箭头图标', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FTile(
            title: const Text('More'),
            suffix: const Icon(FLucideIcons.chevronRight),
          ),
        ),
      );

      expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    });

    testWidgets('点击触发回调', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          FTile(title: const Text('Tap me'), onPress: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
