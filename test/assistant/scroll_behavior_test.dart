import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/assistant/presentation/pages/page.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_stack.dart';

import '../helpers/test_forui_app.dart';

void main() {
  test('near-latest threshold uses reverse-list offset semantics', () {
    expect(assistantIsNearLatest(0), isTrue);
    expect(assistantIsNearLatest(96), isTrue);
    expect(assistantIsNearLatest(97), isFalse);
  });

  testWidgets('scroll-to-latest animates a reverse list to offset zero', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      TestForuiApp(
        home: SizedBox(
          height: 120,
          child: ListView.builder(
            reverse: true,
            controller: controller,
            itemCount: 30,
            itemBuilder: (_, index) =>
                SizedBox(height: 40, child: Text('message-$index')),
          ),
        ),
      ),
    );
    await tester.pump();

    controller.jumpTo(controller.position.maxScrollExtent);
    expect(controller.offset, greaterThan(0));

    final scrollFuture = scrollAssistantToLatest(controller);
    await tester.pumpAndSettle();
    await scrollFuture;

    expect(controller.offset, 0);
  });
}
