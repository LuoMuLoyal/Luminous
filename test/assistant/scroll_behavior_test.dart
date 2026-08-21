import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('FlowChatScreen jumps a reverse FlowThread to latest', (
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
          child: FlowChatScreen(
            thread: FlowThread(
              messages: messages,
              controller: controller,
              padding: EdgeInsets.zero,
              itemSpacing: 8,
            ),
            threadController: controller,
            jumpToLatestTooltip: 'jump-to-latest',
          ),
        ),
      ),
    );
    await tester.pump();

    controller.jumpTo(controller.position.maxScrollExtent);
    expect(controller.offset, greaterThan(0));

    await tester.pump();
    final jumpButton = find.byTooltip('jump-to-latest');
    expect(jumpButton, findsOneWidget);

    await tester.tap(jumpButton);
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });
}
