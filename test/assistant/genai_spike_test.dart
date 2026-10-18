// P0 spike (temporary) for plans/2026-10-18-assistant-chat-ui-migration.md §三 U1.
//
// Question: can flutter_gen_ai_chat_ui (built on framework `package:flutter/material.dart`)
// render inside a `material_ui`-rooted app (the Luminous app root) once the assistant
// subtree installs a framework `Theme` + `Material`?
//
// Delete this file once the P0 go/no-go decision is recorded.
import 'package:flutter/material.dart' as fw;
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;

void main() {
  const user = ChatUser(id: 'user', name: '我');
  const ai = ChatUser(id: 'ai', name: '助手');

  fw.Widget chat(ChatMessagesController controller) => AiChatWidget(
    currentUser: user,
    aiUser: ai,
    controller: controller,
    onSendMessage: (_) {},
  );

  // Framework MaterialLocalizations mirror the app (bootstrap.dart registers the
  // fl.* delegates alongside material_ui's own).
  const frameworkDelegates = <fw.LocalizationsDelegate<dynamic>>[
    fl.GlobalMaterialLocalizations.delegate,
    fl.GlobalWidgetsLocalizations.delegate,
    fl.GlobalCupertinoLocalizations.delegate,
  ];

  testWidgets('baseline — gen_ai under a framework MaterialApp', (
    tester,
  ) async {
    final controller = ChatMessagesController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(fw.MaterialApp(home: chat(controller)));
    await tester.pump();
    // ignore: avoid_print
    print('BASELINE exception: ${tester.takeException()}');
    expect(find.byType(AiChatWidget), findsOneWidget);
  });

  testWidgets('probe — does framework Theme.of see the material_ui root?', (
    tester,
  ) async {
    fw.ThemeData? seen;
    await tester.pumpWidget(
      mui.MaterialApp(
        localizationsDelegates: frameworkDelegates,
        home: fw.Builder(
          builder: (context) {
            seen = fw.Theme.of(context);
            return const fw.SizedBox();
          },
        ),
      ),
    );
    await tester.pump();
    // ignore: avoid_print
    print(
      'FRAMEWORK Theme.of under material_ui root -> '
      'brightness=${seen?.brightness} primary=${seen?.colorScheme.primary} '
      'useMaterial3=${seen?.useMaterial3}',
    );
    // framework MaterialApp default M3 primary is ~#6750A4; distinguish by log.
  });

  testWidgets('material_ui root, NO wrapper, with messages', (tester) async {
    final controller = ChatMessagesController(
      initialMessages: [
        ChatMessage(text: '你好', user: user, createdAt: DateTime(2026)),
        ChatMessage(
          text: '你好，有什么可以帮你的？',
          user: ai,
          createdAt: DateTime(2026),
          isMarkdown: true,
        ),
      ],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      mui.MaterialApp(
        localizationsDelegates: frameworkDelegates,
        home: chat(controller),
      ),
    );
    await tester.pump();
    // ignore: avoid_print
    print('NO-WRAPPER+messages exception: ${tester.takeException()}');
    expect(tester.takeException(), isNull);
  });

  testWidgets('material_ui root, WITH framework Theme + Material wrapper', (
    tester,
  ) async {
    final controller = ChatMessagesController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      mui.MaterialApp(
        localizationsDelegates: frameworkDelegates,
        home: fw.Theme(
          data: fw.ThemeData(useMaterial3: true),
          child: fw.Material(
            type: fw.MaterialType.transparency,
            child: chat(controller),
          ),
        ),
      ),
    );
    await tester.pump();
    final exception = tester.takeException();
    // ignore: avoid_print
    print('WITH-WRAPPER exception: $exception');
    expect(exception, isNull);
  });

  testWidgets('framework Theme installed by the wrapper is what gen_ai sees', (
    tester,
  ) async {
    final controller = ChatMessagesController();
    addTearDown(controller.dispose);
    fw.ColorScheme? seen;
    await tester.pumpWidget(
      mui.MaterialApp(
        localizationsDelegates: frameworkDelegates,
        home: fw.Theme(
          data: fw.ThemeData(
            useMaterial3: true,
            colorScheme: fw.ColorScheme.fromSeed(
              seedColor: const fw.Color(0xFF3366FF),
            ),
          ),
          child: fw.Material(
            type: fw.MaterialType.transparency,
            child: fw.Builder(
              builder: (context) {
                seen = fw.Theme.of(context).colorScheme;
                return chat(controller);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // ignore: avoid_print
    print('WRAPPER-VISIBLE colorScheme primary: ${seen?.primary}');
    expect(seen, isNotNull);
  });
}
