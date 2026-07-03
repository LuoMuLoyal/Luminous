import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

void main() {
  group('FBadge — 状态标签', () {
    testWidgets('FBadge.primary 渲染标签文本', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FBadge(variant: FBadgeVariant.primary, child: const Text('Active')),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('FBadge.raw 支持图标 + 标签', (tester) async {
      await tester.pumpWidget(
        _appShell(const FBadge.raw(builder: _iconLabelBuilder)),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    });

    testWidgets('FBadge.secondary 无图标时只显示文本', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FBadge(variant: FBadgeVariant.secondary, child: const Text('Basic')),
        ),
      );

      expect(find.text('Basic'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.check), findsNothing);
    });

    testWidgets('FBadge.destructive 渲染不同变体', (tester) async {
      await tester.pumpWidget(
        _appShell(
          FBadge(
            variant: FBadgeVariant.destructive,
            child: const Text('Danger'),
          ),
        ),
      );

      expect(find.text('Danger'), findsOneWidget);
    });
  });
}

/// Reusable builder for icon + label badge.
Widget _iconLabelBuilder(BuildContext context, FBadgeStyle style) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(FLucideIcons.check, size: 14),
      const SizedBox(width: 4),
      const Text('Verified'),
    ],
  );
}
