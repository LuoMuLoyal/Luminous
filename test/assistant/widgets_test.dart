import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart';
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
