import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';
import 'package:luminous/features/assistant/presentation/widgets/chat_adapter.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';

AssistantMessage _user(String content, DateTime createdAt) => AssistantMessage(
  role: AssistantMessageRole.user,
  content: content,
  createdAt: createdAt,
);

AssistantMessage _assistant(
  String content,
  DateTime createdAt, {
  List<AssistantToolDetail> toolDetails = const <AssistantToolDetail>[],
  bool replaced = false,
}) => AssistantMessage(
  role: AssistantMessageRole.assistant,
  content: content,
  createdAt: createdAt,
  toolDetails: toolDetails,
  replaced: replaced,
);

const _thinking = '正在思考';

void main() {
  setUp(() {
    KvTestStore.install();
  });

  final base = DateTime.parse('2026-06-18T01:00:00Z');

  group('mapping', () {
    const adapter = AssistantChatAdapter();

    test('maps persisted messages newest-first and keeps the role', () {
      // gen_ai renders a reverse list: index 0 is the newest turn (bottom).
      final messages = [
        _user('hi', base),
        _assistant('**yo**', base.add(const Duration(minutes: 1))),
      ];

      final mapped = adapter.mapMessages(
        conversationId: 'c',
        messages: messages,
        thinkingLabel: _thinking,
      );

      expect(mapped, hasLength(2));
      expect(mapped[0].user.id, 'assistant');
      expect(mapped[0].text, '**yo**');
      expect(mapped[0].isMarkdown, isTrue);
      expect(mapped[1].user.id, 'user');
      expect(mapped[1].text, 'hi');
      expect(mapped[1].isMarkdown, isFalse);
    });

    test('uses the conversation-scoped id without changing the domain id', () {
      final message = _user('hi', base);

      final mapped = adapter.mapMessage(message, conversationId: 'c', index: 3);

      expect(
        adapter.chatMessageId(message, conversationId: 'c', index: 3),
        'c:3:${messageIdFor(message)}',
      );
      expect(mapped.customProperties!['id'], 'c:3:${messageIdFor(message)}');
    });

    test('attaches the domain message to assistant turns only', () {
      final user = _user('hi', base);
      final assistant = _assistant('yo', base);

      final mappedUser = adapter.mapMessage(
        user,
        conversationId: 'c',
        index: 0,
      );
      final mappedAssistant = adapter.mapMessage(
        assistant,
        conversationId: 'c',
        index: 1,
      );

      expect(
        mappedUser.customProperties!.containsKey('assistantMessage'),
        isFalse,
      );
      expect(
        mappedAssistant.customProperties!['assistantMessage'],
        same(assistant),
      );
    });

    test('prepends the streaming draft and skips the loading placeholder', () {
      final messages = [_user('hi', base)];

      final mapped = adapter.mapMessages(
        conversationId: 'c',
        messages: messages,
        thinkingLabel: _thinking,
        streamingDraft: 'partial',
        isSending: true,
        pending: true,
      );

      expect(mapped, hasLength(2));
      expect(mapped.first.text, 'partial');
      expect(mapped.first.customProperties!['id'], assistantStreamingMessageId);
      expect(mapped.first.isMarkdown, isTrue);
      expect(mapped.first.user.id, 'assistant');
    });

    test('prepends the loading placeholder before the first chunk', () {
      final mapped = adapter.mapMessages(
        conversationId: 'c',
        messages: [_user('hi', base)],
        thinkingLabel: _thinking,
        isSending: true,
        pending: true,
      );

      expect(mapped, hasLength(2));
      expect(mapped.first.text, _thinking);
      expect(mapped.first.customProperties!['id'], assistantLoadingMessageId);
      expect(mapped.first.customProperties!['isLoading'], isTrue);
    });

    test('adds nothing while idle', () {
      final mapped = adapter.mapMessages(
        conversationId: 'c',
        messages: [_user('hi', base), _assistant('yo', base)],
        thinkingLabel: _thinking,
      );

      expect(mapped, hasLength(2));
    });

    test('mapStreamingDraft keeps an explicit createdAt stable', () {
      final stamp = base.add(const Duration(seconds: 5));

      final draft = adapter.mapStreamingDraft('x', createdAt: stamp);

      expect(draft.createdAt, stamp);
      expect(draft.customProperties!['id'], assistantStreamingMessageId);
      expect(draft.isMarkdown, isTrue);
      expect(draft.user.id, 'assistant');
    });

    test('mapLoading honours a custom id', () {
      final loading = adapter.mapLoading(_thinking, id: 'custom');

      expect(loading.customProperties!['id'], 'custom');
      expect(loading.text, _thinking);
    });
  });

  group('buildBubble', () {
    Future<void> pumpBubble(
      WidgetTester tester,
      AssistantChatAdapter adapter,
      ChatMessage message, {
      required bool isUser,
    }) {
      return tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => adapter.buildBubble(
                context,
                message,
                isUser,
                const Text('default'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('returns the default bubble for a user turn without resend', (
      tester,
    ) async {
      const adapter = AssistantChatAdapter();

      await pumpBubble(
        tester,
        adapter,
        ChatMessage(text: 'hi', user: chatCurrentUser, createdAt: base),
        isUser: true,
      );

      expect(find.text('default'), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionRefresh), findsNothing);
    });

    testWidgets('adds a resend action to a user turn', (tester) async {
      final resent = <String>[];
      final adapter = AssistantChatAdapter(onResend: resent.add);

      await pumpBubble(
        tester,
        adapter,
        ChatMessage(text: 'hi', user: chatCurrentUser, createdAt: base),
        isUser: true,
      );

      expect(find.text('default'), findsOneWidget);
      await tester.tap(find.byIcon(SemanticIcons.actionRefresh));
      await tester.pumpAndSettle();
      expect(resent, ['hi']);
    });

    testWidgets('marks a replaced assistant answer', (tester) async {
      const adapter = AssistantChatAdapter();

      await pumpBubble(
        tester,
        adapter,
        ChatMessage(
          text: 'yo',
          user: chatAssistantUser,
          createdAt: base,
          isMarkdown: true,
          customProperties: {
            'assistantMessage': _assistant('yo', base, replaced: true),
          },
        ),
        isUser: false,
      );

      expect(find.byKey(const Key('assistant-replaced-label')), findsOneWidget);
      expect(find.text('已替换'), findsOneWidget);
    });

    testWidgets('passes through non-domain assistant turns (draft/loading)', (
      tester,
    ) async {
      const adapter = AssistantChatAdapter();

      await pumpBubble(
        tester,
        adapter,
        ChatMessage(
          text: 'partial',
          user: chatAssistantUser,
          createdAt: base,
          customProperties: const {'id': assistantStreamingMessageId},
        ),
        isUser: false,
      );

      expect(find.text('default'), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionCopy), findsNothing);
    });

    testWidgets('renders the copy action and the tool disclaimer', (
      tester,
    ) async {
      const adapter = AssistantChatAdapter();
      final message = _assistant(
        'yo',
        base,
        toolDetails: const <AssistantToolDetail>[
          AssistantToolDetail(name: 't', disclaimer: '工具免责声明'),
        ],
      );

      await pumpBubble(
        tester,
        adapter,
        ChatMessage(
          text: 'yo',
          user: chatAssistantUser,
          createdAt: base,
          isMarkdown: true,
          customProperties: {'assistantMessage': message},
        ),
        isUser: false,
      );

      expect(find.byIcon(SemanticIcons.actionCopy), findsOneWidget);
      expect(find.text('工具免责声明'), findsOneWidget);
    });
  });
}
