import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('FlowChatView jumps a reverse FlowThread to latest', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final messages = List<FlowMessageData>.generate(
      30,
      (index) => FlowMessageData.text(
        id: 'message-$index',
        role: index.isEven ? FlowMessageRole.user : FlowMessageRole.assistant,
        text: 'Message $index with enough content to create scroll range.',
      ),
    );

    await tester.pumpWidget(
      TestForuiApp(
        home: SizedBox(
          height: 320,
          child: FlowChatView(
            // 只读断言:0.3.0 起 composer 是 required(可为 null),这里显式
            // 声明「没有输入框」。
            composer: null,
            thread: FlowThread(
              messages: messages,
              controller: controller,
              padding: EdgeInsets.zero,
              itemSpacing: 8,
            ),
            threadController: controller,
            jumpToLatestTooltip: '跳转到最新',
          ),
        ),
      ),
    );
    await tester.pump();

    controller.jumpTo(controller.position.maxScrollExtent);
    expect(controller.offset, greaterThan(0));

    // flow_ui 0.3.0 gates the button behind a 250 ms debounce (offset must
    // stay past the threshold before `_showJump` flips); until then the button
    // sits inside an IgnorePointer. Pump past the debounce before tapping.
    await tester.pump();
    final jumpButton = find.byTooltip('跳转到最新');
    expect(jumpButton, findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tester.tap(jumpButton);
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });
}
