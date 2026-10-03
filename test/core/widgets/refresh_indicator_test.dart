import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/feedback/refresh_indicator.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  group('ForuiRefreshIndicator', () {
    Future<void> pump(WidgetTester tester, {required VoidCallback onRefresh}) {
      return tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: ForuiRefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 80, child: Text('row'))],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('idles without the Material spinner or a running animation', (
      tester,
    ) async {
      await pump(tester, onRefresh: () {});

      // Material 的圆形 spinner 不再出现;空闲时 Forui 指示器也不挂载,
      // 否则 FCircularProgress 的无限动画会让 pumpAndSettle 永远等不到静止。
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(find.byType(FCircularProgress), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('shows the Forui indicator while pulling and refreshes once', (
      tester,
    ) async {
      var refreshes = 0;
      await pump(tester, onRefresh: () => refreshes += 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('row')),
      );
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();

      expect(find.byType(FCircularProgress), findsOneWidget);

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(refreshes, 1);
    });
  });
}
