import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/empty_conversation.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

void main() {
  group('AssistantEmptyConversation', () {
    // gen_ai wraps `WelcomeMessageConfig.builder` with a SingleChildScrollView +
    // Center (see `AiChatWidget`); mirror that here so the widget is exercised
    // under the same constraints it sees in production.
    Future<void> pumpAsWelcome(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: AssistantEmptyConversation(
                  onStarterPrompt: (_) {},
                  showMemoryHint: false,
                  showDisclaimerExpanded: true,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders the welcome copy inside the chat scroll area', (
      tester,
    ) async {
      await pumpAsWelcome(tester, const Size(320, 640));
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      expect(tester.takeException(), isNull);
      expect(find.text(l10n.assistantWelcomeTitle), findsOneWidget);
      expect(find.text(l10n.assistantWelcomeDescription), findsOneWidget);
    });

    testWidgets('does not overflow when the viewport shrinks', (tester) async {
      // 键盘弹出后会话区只剩很小的高度:内容加大外层可滚动区,不得溢出/重叠。
      await pumpAsWelcome(tester, const Size(320, 240));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
