import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/feedback/app_toast.dart';

import '../../helpers/test_forui_app.dart';

/// Builds a Forui-aware test shell so the toast widget can resolve its theme.
Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

void main() {
  group('AppToast.show — graceful degradation', () {
    testWidgets('returns false when no FToaster ancestor exists', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppToast.show(context, 'Test message');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Without FToaster in the tree, showFToast throws → caught → returns false
      expect(result, isFalse);
    });

    testWidgets('does not crash when no overlay ancestor exists', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () async {
                    result = await AppToast.show(context, 'No overlay');
                  },
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      // No FToaster + no overlay → both checks fail → returns false
      expect(result, isFalse);
    });
  });

  // Forui 0.23.0 的 LateInitializationError bug 使 FToaster 在测试中不可用
  // 升级至 Forui 0.24+ 后可恢复完整的 toast 行为测试
}
