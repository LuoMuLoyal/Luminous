import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/empty_conversation.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

void main() {
  group('AssistantEmptyConversation', () {
    Future<void> pumpAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: AssistantEmptyConversation(
              onStarterPrompt: (_) {},
              showMemoryHint: false,
              showDisclaimerExpanded: true,
            ),
          ),
        ),
      );
    }

    testWidgets('fills a phone viewport without overflowing', (tester) async {
      await pumpAt(tester, const Size(320, 640));
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(tester.takeException(), isNull);
      expect(find.text(l10n.assistantWelcomeTitle), findsOneWidget);
      expect(find.text(l10n.assistantWelcomeDescription), findsOneWidget);
    });

    testWidgets('scrolls instead of overflowing when the viewport shrinks', (
      tester,
    ) async {
      // 键盘弹出后会话区只剩很小的高度:内容必须可滚动,而不是溢出/重叠。
      await pumpAt(tester, const Size(320, 240));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
