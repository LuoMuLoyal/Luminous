import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/input_bar.dart';

import '../helpers/test_forui_app.dart';

Finder _composer() => find.byType(FlowComposer);

Finder _composerTextField() =>
    find.descendant(of: _composer(), matching: find.byType(TextField));

Finder _composerSendButton() =>
    find.descendant(of: _composer(), matching: find.byType(InkWell));

Widget _shell(Widget child) {
  return TestForuiApp(home: FScaffold(child: child));
}

AssistantInputBar _inputBar({
  required TextEditingController controller,
  required bool canSend,
  required bool isSending,
  required bool canSendMessages,
  required Future<void> Function() onSend,
}) {
  return AssistantInputBar(
    controller: controller,
    canSend: canSend,
    isSending: isSending,
    canSendMessages: canSendMessages,
    onSend: onSend,
  );
}

void main() {
  testWidgets('renders FlowComposer with the existing multiline hint', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _shell(
        _inputBar(
          controller: controller,
          canSend: true,
          isSending: false,
          canSendMessages: true,
          onSend: () async {},
        ),
      ),
    );

    expect(_composer(), findsOneWidget);
    expect(find.byKey(const Key('assistant-input')), findsOneWidget);
    expect(_composerTextField(), findsOneWidget);
    expect(find.byType(FTextField), findsNothing);

    final textField = tester.widget<TextField>(_composerTextField());
    expect(textField.maxLines, 5);
    expect(textField.decoration?.hintText, '比如：结合我最近几天的睡眠和用药，帮我看看要注意什么。');
  });

  testWidgets('sends trimmed text and clears the shared controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? sentText;

    await tester.pumpWidget(
      _shell(
        _inputBar(
          controller: controller,
          canSend: true,
          isSending: false,
          canSendMessages: true,
          onSend: () async => sentText = controller.text,
        ),
      ),
    );

    await tester.enterText(_composerTextField(), '  hello\nworld  ');
    await tester.pump();
    await tester.tap(_composerSendButton());
    await tester.pump();

    expect(sentText, 'hello\nworld');
    expect(controller.text, isEmpty);
  });

  testWidgets('disables the composer but keeps the disabled hint', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _shell(
        _inputBar(
          controller: controller,
          canSend: false,
          isSending: false,
          canSendMessages: false,
          onSend: () async {},
        ),
      ),
    );

    final composer = tester.widget<FlowComposer>(_composer());
    expect(composer.enabled, isFalse);
    expect(tester.widget<TextField>(_composerTextField()).enabled, isFalse);
    expect(find.byIcon(SemanticIcons.statusPaused), findsOneWidget);
    expect(find.text('AI 对话已关闭，输入暂不可用。点击右上角设置开启后再试。'), findsOneWidget);
  });

  testWidgets('sending disables the composer without a stop button', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _shell(
        _inputBar(
          controller: controller,
          canSend: false,
          isSending: true,
          canSendMessages: true,
          onSend: () async {},
        ),
      ),
    );

    final composer = tester.widget<FlowComposer>(_composer());
    expect(composer.enabled, isFalse);
    expect(composer.isStreaming, isFalse);
    expect(find.byIcon(Icons.stop_rounded), findsNothing);
    expect(find.text('Ctrl/⌘ + Enter 发送'), findsNothing);
  });

  testWidgets('hardware Enter shortcuts do not send and keep editing', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sendCount = 0;

    await tester.pumpWidget(
      _shell(
        _inputBar(
          controller: controller,
          canSend: true,
          isSending: false,
          canSendMessages: true,
          onSend: () async => sendCount++,
        ),
      ),
    );

    await tester.enterText(_composerTextField(), 'before');
    await tester.tap(_composerTextField());
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter, character: '\n');
    await tester.pump();

    expect(sendCount, 0);
    expect(controller.text, 'before');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter, character: '\n');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump();

    expect(sendCount, 0);
    expect(controller.text, 'before');

    await tester.enterText(_composerTextField(), 'before\nfrom text input');
    await tester.pump();

    expect(sendCount, 0);
    expect(controller.text, 'before\nfrom text input');
  });
}
