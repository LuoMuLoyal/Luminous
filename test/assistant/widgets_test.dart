import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/welcome_panel.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/chips.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/message_bubble.dart';

import '../helpers/test_forui_app.dart';

Widget _shell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

void main() {
  group('AssistantToolChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _shell(const AssistantToolChip(label: 'Today Records')),
      );
      expect(find.text('Today Records'), findsOneWidget);
    });
  });

  group('AssistantLoadingView', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(
        _shell(
          const SizedBox(
            height: 800,
            child: SingleChildScrollView(child: AssistantLoadingView()),
          ),
        ),
      );
      expect(find.byType(AssistantLoadingView), findsOneWidget);
    });
  });

  group('AssistantWelcomePanel', () {
    testWidgets('renders welcome copy and forwards starter prompt', (
      tester,
    ) async {
      String? selectedPrompt;

      await tester.pumpWidget(
        _shell(
          AssistantWelcomePanel(
            onStarterPrompt: (prompt) => selectedPrompt = prompt,
          ),
        ),
      );

      expect(find.text('开始和 Luminous 聊天'), findsOneWidget);
      expect(find.text('可以问我最近的睡眠、记录和用药情况。'), findsOneWidget);

      await tester.tap(find.text('总结我今天的记录'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(selectedPrompt, '总结我今天的记录');
    });
  });

  group('AssistantMessageBubble', () {
    testWidgets('renders user message content', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-user',
            role: AssistantMessageRole.user,
            content: 'User message',
            usedTools: <String>[],
          ),
        ),
      );
      expect(find.text('User message'), findsOneWidget);
    });

    testWidgets('uses a readable accent color for user message text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-user-color',
            role: AssistantMessageRole.user,
            content: 'Readable user message',
            usedTools: <String>[],
          ),
        ),
      );

      final messageContext = tester.element(
        find.byType(AssistantMessageBubble),
      );
      final text = tester.widget<SelectableText>(find.byType(SelectableText));

      expect(text.style?.color, SemanticColor.primary.solid(messageContext));
    });

    testWidgets('renders assistant message with context menu', (tester) async {
      await tester.pumpWidget(
        _shell(
          const AssistantMessageBubble(
            messageId: 'msg-assistant',
            role: AssistantMessageRole.assistant,
            content: 'Assistant reply',
            usedTools: <String>[],
          ),
        ),
      );
      expect(find.text('Assistant reply'), findsOneWidget);
      expect(find.byType(FContextMenu), findsOneWidget);
    });
  });

  group('AssistantConversationDrawer', () {
    testWidgets('renders with empty state', (tester) async {
      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: const AssistantState(),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );
      expect(find.text('No conversations'), findsOneWidget);
    });

    testWidgets('groups conversations and highlights current', (tester) async {
      final now = DateTime.now();
      final today = AssistantConversationSummary(
        id: 'today',
        title: 'Today chat',
        status: 'active',
        lastMessageAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final thisWeek = AssistantConversationSummary(
        id: 'this-week',
        title: 'This week chat',
        status: 'active',
        lastMessageAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      );
      final older = AssistantConversationSummary(
        id: 'older',
        title: 'Older chat',
        status: 'active',
        lastMessageAt: now.subtract(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      );

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantState(
              conversationId: 'today',
              recentConversations: [today, thisWeek, older],
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );

      expect(find.text('今天'), findsOneWidget);
      expect(find.text('最近 7 天'), findsOneWidget);
      expect(find.text('更早'), findsOneWidget);
      expect(find.text('当前'), findsOneWidget);
      expect(find.text('Today chat'), findsOneWidget);
      expect(find.text('This week chat'), findsOneWidget);
      expect(find.text('Older chat'), findsOneWidget);
    });

    testWidgets('new conversation button is shown when callback is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: const AssistantState(),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
            onNewConversation: () {},
          ),
        ),
      );
      expect(
        find.byKey(const Key('assistant-sidebar-new-conversation')),
        findsOneWidget,
      );
    });

    testWidgets('filters conversations by title in the drawer search', (
      tester,
    ) async {
      final now = DateTime.now();
      final conversations = <AssistantConversationSummary>[
        AssistantConversationSummary(
          id: 'today',
          title: 'Today chat',
          status: 'active',
          lastMessageAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        AssistantConversationSummary(
          id: 'this-week',
          title: 'This week chat',
          status: 'active',
          lastMessageAt: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        AssistantConversationSummary(
          id: 'older',
          title: 'Older chat',
          status: 'active',
          lastMessageAt: now.subtract(const Duration(days: 8)),
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
      ];

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantState(recentConversations: conversations),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('assistant-conversation-search')),
        'Older',
      );
      await tester.pump();

      expect(find.text('Older chat'), findsOneWidget);
      expect(find.text('Today chat'), findsNothing);
      expect(find.text('This week chat'), findsNothing);
      expect(find.text('今天'), findsNothing);
      expect(find.text('最近 7 天'), findsNothing);
    });

    testWidgets('shows an empty state when the search has no matches', (
      tester,
    ) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        _shell(
          AssistantConversationDrawer(
            state: AssistantState(
              recentConversations: [
                AssistantConversationSummary(
                  id: 'today',
                  title: 'Today chat',
                  status: 'active',
                  lastMessageAt: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ],
            ),
            title: 'History',
            emptyTitle: 'No conversations',
            emptyDescription: 'Start a new chat',
            searchHint: 'Search chat content…',
            searchEmptyTitle: 'No matching chats',
            searchEmptyDescription: 'Try another search.',
            onClose: () {},
            onRetry: () {},
            onSelect: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('assistant-conversation-search')),
        'missing',
      );
      await tester.pump();

      expect(find.text('No matching chats'), findsOneWidget);
      expect(find.text('Today chat'), findsNothing);
    });
  });

  group('Assistant state message', () {
    testWidgets('renders title and description with maxWidth', (tester) async {
      await tester.pumpWidget(
        _shell(
          const StateMessageView(
            maxWidth: 560,
            title: 'Ready',
            description: 'Assistant is active',
            icon: SemanticIcons.statusDone,
          ),
        ),
      );
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Assistant is active'), findsOneWidget);
    });

    testWidgets('renders action button', (tester) async {
      await tester.pumpWidget(
        _shell(
          StateMessageView(
            maxWidth: 560,
            title: 'Error',
            description: 'Something went wrong',
            icon: SemanticIcons.statusError,
            actionLabel: 'Retry',
            onAction: () {},
            tone: StateTone.danger,
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
