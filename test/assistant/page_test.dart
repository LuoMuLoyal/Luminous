import 'dart:async';

import 'package:flutter/material.dart' as f;
import 'package:flutter/services.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/pages/page.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/assistant_greeting.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/loading_view.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/pages/advanced/ai.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';

// The gen_ai chat surface renders with framework (`package:flutter/material.dart`)
// widgets, while the surrounding app is built from `material_ui` / Forui. The
// lookups below are typed against the framework so they match the composer.
Finder _assistantInputTextField() => find.descendant(
  of: find.byKey(const Key('assistant-chat-surface')),
  matching: find.byType(f.TextField),
);

// Tapping must hit the enabled control: gen_ai's `AnimatedSwitcher` keeps the
// outgoing (disabled) glyph in the tree for the duration of the morph.
Finder _assistantSendButton() =>
    find.byKey(const ValueKey('send-stop-button-enabled'));

// Presence check that is agnostic to the empty/non-empty control state.
Finder _assistantSendControl() => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key == const ValueKey('send-stop-button-enabled') ||
      key == const ValueKey('send-stop-button-disabled') ||
      key == const ValueKey('send-stop-button-stop');
});

void main() {
  testWidgets('AI chat page shows sign-in gate when signed out', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        child: TestForuiRouterApp(
          routerConfig: GoRouter(
            initialLocation: '/assistant',
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AssistantPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('登录后可使用 AI 对话，并自行决定开放的健康上下文'), findsOneWidget);
    expect(_assistantInputTextField(), findsNothing);
  });

  testWidgets('send error shows retry button and error-specific icon', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _ErrorStreamAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    // Type and send a message
    final input = _assistantInputTextField();
    expect(input, findsOneWidget);
    await tester.enterText(input, '帮我看看最近的睡眠');
    await tester.pump();
    await tester.tap(_assistantSendButton());
    await tester.pumpAndSettle();

    // Error message and retry button should be visible
    expect(find.text('这次回复没有完成'), findsOneWidget);
    expect(find.byKey(const Key('assistant-retry-action')), findsOneWidget);
    // Server error icon
    expect(find.byIcon(SemanticIcons.statusUnavailable), findsOneWidget);
  });

  testWidgets('assistant message shows proposal card', (tester) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _ProposalAssistantRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_assistantInputTextField(), '帮我记一杯水');
    await tester.pump();
    await tester.tap(_assistantSendButton());
    await tester.pumpAndSettle();

    expect(find.text('保存这条记录'), findsOneWidget);
    expect(find.text('确认保存'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('类型: water'), findsOneWidget);
    expect(find.text('目标: 2026-06-18 water 300 ml'), findsOneWidget);
    expect(find.text('定位方式: relative_today'), findsOneWidget);
    expect(find.text('确认前约束'), findsOneWidget);
    expect(find.text('• 必须先经过你确认，后端不会直接写入。'), findsOneWidget);
  });

  testWidgets(
    'confirm create proposal confirms on the backend without a client write',
    (tester) async {
      KvTestStore.install(seed: const <String, Object>{});
      final repository = _ProposalAssistantRepository();
      final dailyRecordRepository = _FakeDailyRecordRepository();

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          dailyRecordRepository: dailyRecordRepository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(_assistantInputTextField(), '帮我记一杯水');
      await tester.pump();
      await tester.tap(_assistantSendButton());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('assistant-proposal-confirm-proposal-create-1')),
      );
      await tester.pumpAndSettle();

      // The write happens server-side: the confirm request carries the approved
      // decision and the client repository is never touched.
      expect(repository.confirmCalls.single.decision, 'approved');
      expect(repository.confirmCalls.single.proposalIds, <String>[
        'proposal-create-1',
      ]);
      expect(
        repository.confirmCalls.single.conversationId,
        'conversation-proposal',
      );
      expect(dailyRecordRepository.createdInputs, isEmpty);
      expect(find.text('已确认'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets(
    'confirm settings proposal confirms on the backend without a client patch',
    (tester) async {
      KvTestStore.install(seed: const <String, Object>{});
      final repository = _SettingsProposalAssistantRepository();
      final settingsController = _TrackingUserSettingsController();

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          settingsController: settingsController,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(_assistantInputTextField(), '关闭记忆');
      await tester.pump();
      await tester.tap(_assistantSendButton());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('assistant-proposal-confirm-proposal-settings-1')),
      );
      await tester.pumpAndSettle();

      expect(repository.confirmCalls.single.decision, 'approved');
      expect(repository.confirmCalls.single.proposalIds, <String>[
        'proposal-settings-1',
      ]);
      // No client-side settings patch anymore — the server applies it.
      expect(settingsController.lastPatch, isNull);
      expect(find.text('已确认'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets('dismiss proposal hides proposal card', (tester) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _ProposalAssistantRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_assistantInputTextField(), '帮我记一杯水');
    await tester.pump();
    await tester.tap(_assistantSendButton());
    await tester.pumpAndSettle();

    expect(find.text('保存这条记录'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('assistant-proposal-dismiss-proposal-create-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('保存这条记录'), findsNothing);
  });

  testWidgets('expired proposal cannot be confirmed and shows expiry hint', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});
    final dailyRecordRepository = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      _buildTestApp(
        repository: _ExpiredProposalAssistantRepository(),
        dailyRecordRepository: dailyRecordRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_assistantInputTextField(), '帮我记一杯水');
    await tester.pump();
    await tester.tap(_assistantSendButton());
    await tester.pumpAndSettle();

    expect(find.text('建议已过期，请重新生成后再确认'), findsOneWidget);
    expect(
      tester
          .widget<FButton>(
            find.byKey(
              const Key('assistant-proposal-confirm-proposal-create-expired'),
            ),
          )
          .onPress,
      isNull,
    );
    expect(dailyRecordRepository.createdInputs, isEmpty);

    // Expired proposals offer a one-tap regenerate entry instead.
    expect(
      find.byKey(
        const Key('assistant-proposal-regenerate-proposal-create-expired'),
      ),
      findsOneWidget,
    );
    expect(find.text('重新生成'), findsOneWidget);
  });

  testWidgets('disabled AI chat shows hint about toggle above', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _DisabledAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('assistant-new-conversation-action')),
      findsOneWidget,
    );

    // Should show hint about toggling in settings
    expect(find.text('AI 对话已关闭，可在右上角设置中开启'), findsOneWidget);
    // With no conversation and sending disabled, the chat (and its composer)
    // is replaced by the explanatory state view.
    expect(find.byType(AiChatWidget), findsNothing);
    expect(_assistantInputTextField(), findsNothing);
    expect(find.byIcon(Icons.stop_rounded), findsNothing);
  });

  testWidgets('disabled AI chat still shows restored history', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _DisabledWithHistoryAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('之前那次睡眠为什么这么差？'), findsOneWidget);
    expect(find.text('我先结合你最近几天的睡眠记录来解释。'), findsOneWidget);
    expect(find.text('AI 对话已关闭，可在右上角设置中开启'), findsNothing);
  });

  testWidgets('latest persisted conversation is restored on assistant page', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _RestoredConversationAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('昨晚睡得不太好'), findsOneWidget);
    expect(find.text('我看到你最近有睡眠记录，可以先从作息规律开始看。'), findsOneWidget);
  });

  testWidgets(
    'new conversation action archives latest conversation through repository',
    (tester) async {
      KvTestStore.install(seed: const <String, Object>{});
      final repository = _RestoredConversationAssistantRepository();

      await tester.pumpWidget(_buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('assistant-new-conversation-action')),
        findsOneWidget,
      );

      await tester.enterText(_assistantInputTextField(), '这条输入会被清空');
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('assistant-new-conversation-action')),
      );
      await tester.pumpAndSettle();

      expect(repository.clearCalls, 1);
      expect(find.text('昨晚睡得不太好'), findsNothing);
      expect(find.text('开始和 Luminous 聊天'), findsOneWidget);
      expect(find.text('这条输入会被清空'), findsNothing);
    },
  );

  testWidgets('retry does not duplicate failed user message', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _RetryAwareAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(_assistantInputTextField(), '帮我看看最近睡眠');
    await tester.pump();
    await tester.tap(_assistantSendButton());
    await tester.pumpAndSettle();

    expect(find.text('这次回复没有完成'), findsOneWidget);
    expect(find.text('帮我看看最近睡眠'), findsOneWidget);

    await tester.tap(find.byKey(const Key('assistant-retry-action')));
    await tester.pumpAndSettle();

    expect(repository.recordedMessageCounts, <int>[1, 1]);
    expect(find.text('帮我看看最近睡眠'), findsOneWidget);
    expect(find.text('先从最近三天入睡时间波动来看。'), findsOneWidget);
  });

  testWidgets('recent conversation drawer opens and switches conversation', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _RecentConversationsAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('assistant-recent-conversations-action')),
      findsOneWidget,
    );

    final mainContentBefore = tester
        .getTopLeft(find.byKey(const Key('assistant-main-content')))
        .dx;

    await tester.tap(
      find.byKey(const Key('assistant-recent-conversations-action')),
    );
    await tester.pumpAndSettle();

    final mainContentAfter = tester
        .getTopLeft(find.byKey(const Key('assistant-main-content')))
        .dx;
    expect(mainContentAfter, greaterThan(mainContentBefore));
    expect(
      find.byKey(const Key('assistant-conversation-drawer')),
      findsOneWidget,
    );
    expect(find.text('会话'), findsOneWidget);
    expect(find.text('睡眠跟进'), findsOneWidget);
    expect(find.text('头痛追踪'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const Key('assistant-recent-conversation-conversation-headache'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.openedConversationIds, <String>['conversation-headache']);
    expect(find.text('今天头痛还在继续'), findsOneWidget);
    expect(find.text('先看一下你最近记录里的触发因素。'), findsOneWidget);
  });

  testWidgets('drawer long-press menu renames a conversation', (tester) async {
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _RecentConversationsAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('assistant-recent-conversations-action')),
    );
    await tester.pumpAndSettle();

    // Long-press opens the Forui context menu with rename + delete entries.
    await tester.longPress(
      find.byKey(
        const Key('assistant-recent-conversation-conversation-headache'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('重命名'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const Key('assistant-conversation-rename-conversation-headache'),
      ),
    );
    await tester.pumpAndSettle();

    // The rename dialog opens and submits the new title through the page.
    expect(
      find.byKey(const Key('assistant-conversation-rename-dialog')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('assistant-conversation-rename-field')),
      '新标题',
    );
    await tester.tap(
      find.byKey(const Key('assistant-conversation-rename-confirm')),
    );
    await tester.pumpAndSettle();

    expect(
      repository.renameCalls.single.conversationId,
      'conversation-headache',
    );
    expect(repository.renameCalls.single.title, '新标题');
  });

  testWidgets(
    'tap-to-name opens the rename dialog for an untitled conversation',
    (tester) async {
      KvTestStore.install(seed: const <String, Object>{});
      final repository = _DrawerMenuAssistantRepository();

      await tester.pumpWidget(_buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('assistant-recent-conversations-action')),
      );
      await tester.pumpAndSettle();

      expect(find.text('点击命名'), findsOneWidget);

      await tester.tap(find.text('点击命名'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('assistant-conversation-rename-dialog')),
        findsOneWidget,
      );
    },
  );

  testWidgets('drawer delete flow confirms before deleting and toasts', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _RecentConversationsAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('assistant-recent-conversations-action')),
    );
    await tester.pumpAndSettle();

    await tester.longPress(
      find.byKey(
        const Key('assistant-recent-conversation-conversation-headache'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const Key('assistant-conversation-delete-conversation-headache'),
      ),
    );
    await tester.pumpAndSettle();

    // The danger confirmation dialog asks again before deleting.
    expect(find.text('删除会话？'), findsOneWidget);
    expect(find.text('删除后不可恢复'), findsOneWidget);

    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, <String>['conversation-headache']);
  });

  testWidgets('assistant header keeps back history new and settings actions', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _FakeAssistantRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('assistant-back-action')), findsOneWidget);
    expect(
      find.byKey(const Key('assistant-recent-conversations-action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('assistant-new-conversation-action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('assistant-status-settings-action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('assistant-capabilities-action')),
      findsOneWidget,
    );
  });

  testWidgets('assistant settings action navigates to the dedicated AI page', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _FakeAssistantRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('assistant-status-settings-action')));
    await tester.pumpAndSettle();

    expect(find.text('AI 设置'), findsOneWidget);
  });

  testWidgets('F-10: capabilities action opens the capability details panel', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _FakeAssistantRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('assistant-capabilities-action')));
    await tester.pumpAndSettle();

    // 面板摘要区出现。
    expect(find.text('能力摘要'), findsOneWidget);
    expect(find.text('启用 AI 对话'), findsOneWidget);
  });

  testWidgets('AI chat page renders on mobile screen size', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _FakeAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    // Input field should be visible on mobile
    expect(_assistantInputTextField(), findsOneWidget);
    expect(_assistantSendControl(), findsWidgets);
  });

  testWidgets('page send trims input and clears the shared controller', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});
    final repository = _RecordingAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(_assistantInputTextField(), '  帮我看看睡眠  ');
    await tester.pump();
    await tester.tap(_assistantSendButton());
    await tester.pumpAndSettle();

    final textField = tester.widget<f.TextField>(_assistantInputTextField());
    expect(textField.controller?.text, isEmpty);
    expect(repository.sentMessageBatches, hasLength(1));
    expect(repository.sentMessageBatches.single.single.content, '帮我看看睡眠');
  });

  testWidgets(
    'page composer sends on hardware Enter and keeps Shift+Enter newline',
    (tester) async {
      KvTestStore.install(seed: const <String, Object>{});
      final repository = _RecordingAssistantRepository();

      await tester.pumpWidget(_buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.enterText(_assistantInputTextField(), 'send me');
      await tester.tap(_assistantInputTextField());
      await tester.pump();

      // Shift+Enter inserts a newline instead of sending.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter, character: '\n');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      expect(repository.sentMessageBatches, isEmpty);

      // Plain Enter sends — what a hardware keyboard user expects.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter, character: '\n');
      await tester.pumpAndSettle();

      expect(repository.sentMessageBatches, isNotEmpty);
    },
  );

  testWidgets('page composer preserves the gen_ai input contract', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _FakeAssistantRepository()),
    );
    await tester.pumpAndSettle();

    // gen_ai's composer is a framework TextField whose Enter handling is
    // driven by `InputOptions.sendOnEnter` (package default: Enter sends,
    // Shift+Enter makes a newline).
    final textField = tester.widget<f.TextField>(_assistantInputTextField());
    expect(textField.maxLines, 5);
    expect(textField.decoration?.hintText, '问问你的健康数据…');
    expect(_assistantSendControl(), findsWidgets);
  });

  testWidgets('normal assistant page uses the gen_ai chat surface', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _RestoredConversationAssistantRepository()),
    );
    await tester.pumpAndSettle();

    final chat = tester.widget<AiChatWidget>(find.byType(AiChatWidget));
    expect(find.byKey(const Key('assistant-chat-surface')), findsOneWidget);
    expect(chat.scrollController, isNotNull);
    expect(chat.messages, isNotNull);
    expect(_assistantInputTextField(), findsOneWidget);
  });

  testWidgets('assistant chat list scrolls a long conversation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _LongConversationAssistantRepository()),
    );
    await tester.pumpAndSettle();

    // The gen_ai message list is a ListView bound to the surface's scroll
    // controller; a 30-message conversation overflows the viewport, so one of
    // the surface's lists must hold a live, scrollable position.
    final controllers = tester
        .widgetList<ListView>(
          find.descendant(
            of: find.byKey(const Key('assistant-chat-surface')),
            matching: find.byType(ListView),
          ),
        )
        .map((listView) => listView.controller)
        .whereType<ScrollController>();
    final scrollable = controllers.where(
      (controller) =>
          controller.hasClients && controller.position.maxScrollExtent > 0,
    );
    expect(scrollable, isNotEmpty);
  });

  testWidgets('empty assistant page keeps greeting and welcome support copy', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _FakeAssistantRepository()),
    );
    await tester.pumpAndSettle();

    // 空态由 gen_ai 的 WelcomeMessageConfig.builder 渲染，内容仍是本仓的
    // AssistantEmptyConversation(有界、可滚动)，不是语料的默认空态。
    expect(find.byType(AiChatWidget), findsOneWidget);
    expect(find.byType(AssistantSvgGreeting), findsOneWidget);
    expect(find.text('开始和 Luminous 聊天'), findsOneWidget);
    expect(find.text('可以问最近的睡眠、记录和用药'), findsOneWidget);
    for (final prompt in const [
      '总结我今天的记录',
      '我最近睡眠怎么样',
      '我当前在吃什么药',
      '帮我看看要注意什么',
    ]) {
      expect(find.text(prompt), findsOneWidget);
    }
    const starterPrompt = '总结我今天的记录';
    await tester.tap(find.text(starterPrompt));
    await tester.pump();
    final composerTextField = tester.widget<f.TextField>(
      _assistantInputTextField(),
    );
    expect(composerTextField.controller?.text, starterPrompt);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('AI 回答仅供参考，不构成医疗建议；用药调整请咨询医生'), findsOneWidget);
    expect(
      find.byKey(const Key('assistant-welcome-disclaimer')),
      findsOneWidget,
    );
    expect(find.byIcon(SemanticIcons.actionCollapse), findsOneWidget);
    final disclaimer = find.byKey(const Key('assistant-welcome-disclaimer'));
    await tester.ensureVisible(disclaimer);
    await tester.tap(disclaimer);
    await tester.pump();
    expect(
      tester.widget<Text>(find.text('AI 回答仅供参考，不构成医疗建议；用药调整请咨询医生')).maxLines,
      1,
    );
    expect(find.byIcon(SemanticIcons.actionExpand), findsOneWidget);
  });

  testWidgets('empty assistant page shows the memory hint when enabled', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _MemoryEnabledAssistantRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('已开启跨会话记忆'), findsOneWidget);
    expect(find.text('对话会被提炼为要点用于后续会话，可在设置中关闭'), findsOneWidget);
  });

  testWidgets('AssistantPage scopes one chat theme bridge below MaterialApp', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _FakeAssistantRepository()),
    );
    await tester.pumpAndSettle();

    // The gen_ai surface must receive a framework Theme carrying the
    // CustomThemeExtension that maps Forui tokens onto the package widgets.
    final chatThemes = tester
        .widgetList<f.Theme>(
          find.ancestor(
            of: find.byKey(const Key('assistant-chat-surface')),
            matching: find.byType(f.Theme),
          ),
        )
        .where((theme) => theme.data.extension<CustomThemeExtension>() != null)
        .toList();

    expect(chatThemes, hasLength(1));
  });

  testWidgets('AI chat page shows loading skeleton while capabilities load', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    KvTestStore.install(seed: const <String, Object>{});

    final pendingCapabilities = Completer<AssistantCapabilities>();
    final pendingConversation = Completer<AssistantConversation?>();
    final repository = _FullyHangingAssistantRepository(
      pendingCapabilities,
      pendingConversation,
    );

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pump();

    // Loading skeleton should appear while capabilities and conversation load
    expect(find.byType(AssistantLoadingView), findsOneWidget);
    // Input field should NOT be visible during loading
    expect(_assistantInputTextField(), findsNothing);

    // Complete loading
    pendingConversation.complete(null);
    pendingCapabilities.complete(_FakeAssistantRepository._capabilities);
    await tester.pumpAndSettle();

    // After loading, skeleton disappears and input appears
    expect(find.byType(AssistantLoadingView), findsNothing);
    expect(_assistantInputTextField(), findsOneWidget);
  });
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

/// Stubs the backend proposal confirmation for repositories. Records calls so
/// tests can assert the confirm request (the real write happens server-side,
/// F-11).
mixin _ConfirmProposalsStub implements AssistantRepository {
  final List<
    ({String conversationId, List<String> proposalIds, String decision})
  >
  confirmCalls =
      <({String conversationId, List<String> proposalIds, String decision})>[];

  @override
  TaskEither<LucentFailure, String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) {
    confirmCalls.add((
      conversationId: conversationId,
      proposalIds: proposalIds,
      decision: decision,
    ));
    return TaskEither.right(null);
  }

  final List<({String conversationId, String title})> renameCalls =
      <({String conversationId, String title})>[];
  final List<String> deleteCalls = <String>[];

  @override
  TaskEither<LucentFailure, void> renameConversation({
    required String conversationId,
    required String title,
  }) {
    renameCalls.add((conversationId: conversationId, title: title));
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, void> deleteConversation(String conversationId) {
    deleteCalls.add(conversationId);
    return TaskEither.right(null);
  }

  @override
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  }) async* {
    // no-op stub; page tests do not exercise regeneration streaming.
  }
}

class _FakeAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  static const _capabilities = AssistantCapabilities(
    phase: 'phase_1',
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    assistantContext: AssistantContextAccess(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: true,
      currentMedicines: true,
    ),
    chatModelConfigured: true,
    interactiveChatReady: true,
    langGraphReady: true,
    streamingSupported: true,
    streamingTransport: 'sse',
    markdownRenderingRecommended: true,
    ragEnabled: false,
    tools: <AssistantToolCapability>[],
    updatedAt: null,
  );

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _RecordingAssistantRepository extends _FakeAssistantRepository {
  final List<List<AssistantMessage>> sentMessageBatches =
      <List<AssistantMessage>>[];

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    sentMessageBatches.add(List<AssistantMessage>.of(messages));
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _MemoryEnabledAssistantRepository extends _FakeAssistantRepository {
  static const _memoryEnabledCapabilities = AssistantCapabilities(
    phase: 'phase_1',
    assistantEnabled: true,
    assistantMemoryEnabled: true,
    assistantContext: AssistantContextAccess(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: true,
      currentMedicines: true,
    ),
    chatModelConfigured: true,
    interactiveChatReady: true,
    langGraphReady: true,
    streamingSupported: true,
    streamingTransport: 'sse',
    markdownRenderingRecommended: true,
    ragEnabled: false,
    tools: <AssistantToolCapability>[],
    updatedAt: null,
  );

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_memoryEnabledCapabilities);
  }
}

Widget _buildTestApp({
  required AssistantRepository repository,
  DailyRecordRepository? dailyRecordRepository,
  UserSettingsController? settingsController,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
      assistantRepositoryProvider.overrideWithValue(repository),
      dailyRecordRepositoryProvider.overrideWithValue(
        dailyRecordRepository ?? _FakeDailyRecordRepository(),
      ),
      userSettingsControllerProvider.overrideWith(
        () => settingsController ?? _ReadyUserSettingsController(),
      ),
    ],
    child: TestForuiRouterApp(
      routerConfig: GoRouter(
        initialLocation: '/assistant',
        routes: [
          GoRoute(
            path: '/assistant',
            builder: (context, state) => const AssistantPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('login-page')),
          ),
          GoRoute(
            path: '/settings/ai',
            builder: (context, state) => const AiSettingsPage(),
          ),
        ],
      ),
    ),
  );
}

class _ReadyUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: true,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: true,
        dailyRecords: true,
        sleepRecords: true,
        currentMedicines: true,
      ),
      updatedAt: null,
    );
  }
}

class _TrackingUserSettingsController extends _ReadyUserSettingsController {
  ({
    bool aiSummariesEnabled,
    bool dataSharingConsent,
    bool assistantEnabled,
    bool assistantMemoryEnabled,
    int waterTargetCount,
    AssistantContextPatch assistantContext,
  })?
  lastPatch;

  @override
  Future<void> applySettingsPatch({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) async {
    lastPatch = (
      aiSummariesEnabled: aiSummariesEnabled,
      dataSharingConsent: dataSharingConsent,
      assistantEnabled: assistantEnabled,
      assistantMemoryEnabled: assistantMemoryEnabled,
      waterTargetCount: waterTargetCount,
      assistantContext: assistantContext,
    );
  }
}

class _ErrorStreamAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return Stream<AssistantGenerationEvent>.error(
      const LucentFailure(
        kind: LucentFailureKind.server,
        message: 'Server error.',
        statusCode: 503,
      ),
    );
  }
}

class _ProposalAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return Stream<AssistantGenerationEvent>.fromIterable([
      AssistantGenerationResultEvent(
        conversationId: 'conversation-proposal',
        message: AssistantMessage(
          role: AssistantMessageRole.assistant,
          content: '我已经整理成一条可确认的记录建议。',
          createdAt: DateTime.parse('2026-06-18T03:00:00Z'),
          proposedActions: <AssistantProposedAction>[
            AssistantProposedAction(
              id: 'proposal-create-1',
              type: AssistantProposedActionType.createDailyRecord,
              title: '保存这条记录',
              summary: '准备保存一条 2026-06-18 的 water 记录。',
              reason: 'Detected water intake.',
              previewFields: <AssistantProposalPreviewField>[
                const AssistantProposalPreviewField(
                  label: '类型',
                  value: 'water',
                ),
              ],
              target: const AssistantProposalTarget(
                kind: 'daily_record_draft',
                label: '2026-06-18 water 300 ml',
                matchedBy: <String>['relative_today'],
              ),
              constraints: <String>['必须先经过你确认，后端不会直接写入。'],
              expiresAt: DateTime.now().add(const Duration(minutes: 15)),
              payloadVersion: 1,
              payload: const AssistantCreateDailyRecordProposalPayload(
                draft: AssistantCreateDailyRecordDraft(
                  kind: 'water',
                  occurredAt: '2026-06-18',
                  title: null,
                  value: '300',
                  unit: 'ml',
                  note: null,
                  payload: null,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _SettingsProposalAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return Stream<AssistantGenerationEvent>.fromIterable([
      AssistantGenerationResultEvent(
        conversationId: 'conversation-settings-proposal',
        message: AssistantMessage(
          role: AssistantMessageRole.assistant,
          content: '我整理出了一组设置变更。',
          createdAt: DateTime.parse('2026-06-18T03:30:00Z'),
          proposedActions: <AssistantProposedAction>[
            AssistantProposedAction(
              id: 'proposal-settings-1',
              type: AssistantProposedActionType.updateUserSettings,
              title: '更新助手相关设置',
              summary: '我整理出了一组设置变更，确认后才会真正写入。',
              reason: null,
              previewFields: <AssistantProposalPreviewField>[
                const AssistantProposalPreviewField(
                  label: '持久化记忆',
                  value: '关闭',
                ),
              ],
              target: const AssistantProposalTarget(
                kind: 'user_settings',
                label: '助手设置',
                settingKeys: <String>['assistantMemoryEnabled'],
              ),
              constraints: <String>['必须先经过你确认，后端不会直接写入。'],
              expiresAt: DateTime.now().add(const Duration(minutes: 15)),
              payloadVersion: 1,
              payload: const AssistantUpdateUserSettingsProposalPayload(
                draft: AssistantUpdateUserSettingsDraft(
                  assistantMemoryEnabled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _ExpiredProposalAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return Stream<AssistantGenerationEvent>.fromIterable([
      AssistantGenerationResultEvent(
        conversationId: 'conversation-proposal-expired',
        message: AssistantMessage(
          role: AssistantMessageRole.assistant,
          content: '这是一条已经过期的建议。',
          createdAt: DateTime.parse('2026-06-18T04:00:00Z'),
          proposedActions: <AssistantProposedAction>[
            AssistantProposedAction(
              id: 'proposal-create-expired',
              type: AssistantProposedActionType.createDailyRecord,
              title: '保存这条记录',
              summary: '这条建议已经过期。',
              reason: 'Expired test fixture.',
              previewFields: <AssistantProposalPreviewField>[
                const AssistantProposalPreviewField(
                  label: '类型',
                  value: 'water',
                ),
              ],
              target: const AssistantProposalTarget(
                kind: 'daily_record_draft',
                label: '2026-06-18 water 300 ml',
                matchedBy: <String>['relative_today'],
              ),
              constraints: <String>['必须先经过你确认，后端不会直接写入。'],
              expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
              payloadVersion: 1,
              payload: const AssistantCreateDailyRecordProposalPayload(
                draft: AssistantCreateDailyRecordDraft(
                  kind: 'water',
                  occurredAt: '2026-06-18',
                  title: null,
                  value: '300',
                  unit: 'ml',
                  note: null,
                  payload: null,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _DisabledAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(
      const AssistantCapabilities(
        phase: 'phase_1',
        assistantEnabled: false,
        assistantMemoryEnabled: false,
        assistantContext: AssistantContextAccess(
          healthProfile: true,
          dailyRecords: true,
          sleepRecords: true,
          currentMedicines: true,
        ),
        chatModelConfigured: true,
        interactiveChatReady: true,
        langGraphReady: true,
        streamingSupported: true,
        streamingTransport: 'sse',
        markdownRenderingRecommended: true,
        ragEnabled: false,
        tools: <AssistantToolCapability>[],
        updatedAt: null,
      ),
    );
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _DisabledWithHistoryAssistantRepository
    extends _DisabledAssistantRepository {
  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(
      AssistantConversation(
        id: 'conversation-disabled-history',
        title: '睡眠复盘',
        status: 'active',
        messages: <AssistantMessage>[
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: '之前那次睡眠为什么这么差？',
            createdAt: DateTime.parse('2026-06-18T02:00:00Z'),
          ),
          AssistantMessage(
            role: AssistantMessageRole.assistant,
            content: '我先结合你最近几天的睡眠记录来解释。',
            createdAt: DateTime.parse('2026-06-18T02:01:00Z'),
          ),
        ],
        lastMessageAt: DateTime.parse('2026-06-18T02:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T02:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T02:01:00Z'),
      ),
    );
  }
}

class _RestoredConversationAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  int clearCalls = 0;

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(<AssistantConversationSummary>[
      AssistantConversationSummary(
        id: 'conversation-restored',
        title: '睡眠跟进',
        status: 'active',
        lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
      ),
    ]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(
      AssistantConversation(
        id: 'conversation-restored',
        title: '睡眠跟进',
        status: 'active',
        messages: <AssistantMessage>[
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: '昨晚睡得不太好',
            createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
          ),
          AssistantMessage(
            role: AssistantMessageRole.assistant,
            content: '我看到你最近有睡眠记录，可以先从作息规律开始看。',
            createdAt: DateTime.parse('2026-06-18T01:01:00Z'),
            usedTools: const <String>['get_sleep_summary_by_range'],
          ),
        ],
        lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    return getLatestConversation().map((conversation) => conversation!);
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    clearCalls += 1;
    return TaskEither.right(true);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _LongConversationAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(
      AssistantConversation(
        id: 'conversation-long',
        title: '长对话',
        status: 'active',
        messages: <AssistantMessage>[
          for (var index = 0; index < 30; index += 1)
            AssistantMessage(
              role: index.isEven
                  ? AssistantMessageRole.user
                  : AssistantMessageRole.assistant,
              content: '第 $index 条消息，内容足够长以形成可滚动范围。',
              createdAt: DateTime.parse(
                '2026-06-18T01:00:00Z',
              ).add(Duration(minutes: index)),
            ),
        ],
        lastMessageAt: DateTime.parse('2026-06-18T01:29:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:29:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    return getLatestConversation().map((conversation) => conversation!);
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(true);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _RetryAwareAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  _RetryAwareAssistantRepository();

  final List<int> recordedMessageCounts = <int>[];
  int _attempt = 0;

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) async* {
    recordedMessageCounts.add(messages.length);
    _attempt += 1;

    if (_attempt == 1) {
      throw const LucentFailure(
        kind: LucentFailureKind.server,
        message: 'Server error.',
        statusCode: 503,
      );
    }

    yield const AssistantGenerationChunkEvent('先从最近三天入睡时间波动来看。');
    yield AssistantGenerationResultEvent(
      conversationId: 'conversation-retry',
      message: AssistantMessage(
        role: AssistantMessageRole.assistant,
        content: '先从最近三天入睡时间波动来看。',
        createdAt: DateTime.now(),
      ),
    );
  }
}

class _RecentConversationsAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  final List<String> openedConversationIds = <String>[];

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(<AssistantConversationSummary>[
      AssistantConversationSummary(
        id: 'conversation-restored',
        title: '睡眠跟进',
        status: 'active',
        lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
      ),
      AssistantConversationSummary(
        id: 'conversation-headache',
        title: '头痛追踪',
        status: 'archived',
        lastMessageAt: DateTime.parse('2026-06-17T09:01:00Z'),
        createdAt: DateTime.parse('2026-06-17T09:00:00Z'),
        updatedAt: DateTime.parse('2026-06-17T09:01:00Z'),
      ),
    ]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(
      AssistantConversation(
        id: 'conversation-restored',
        title: '睡眠跟进',
        status: 'active',
        messages: <AssistantMessage>[
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: '昨晚睡得不太好',
            createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
          ),
          AssistantMessage(
            role: AssistantMessageRole.assistant,
            content: '我看到你最近有睡眠记录，可以先从作息规律开始看。',
            createdAt: DateTime.parse('2026-06-18T01:01:00Z'),
          ),
        ],
        lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    openedConversationIds.add(conversationId);
    return TaskEither.right(
      AssistantConversation(
        id: 'conversation-headache',
        title: '头痛追踪',
        status: 'active',
        messages: <AssistantMessage>[
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: '今天头痛还在继续',
            createdAt: DateTime.parse('2026-06-17T09:00:00Z'),
          ),
          AssistantMessage(
            role: AssistantMessageRole.assistant,
            content: '先看一下你最近记录里的触发因素。',
            createdAt: DateTime.parse('2026-06-17T09:01:00Z'),
          ),
        ],
        lastMessageAt: DateTime.parse('2026-06-17T09:01:00Z'),
        createdAt: DateTime.parse('2026-06-17T09:00:00Z'),
        updatedAt: DateTime.parse('2026-06-17T09:01:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

/// Repository with one titled and one untitled conversation, used to exercise
/// the drawer's tap-to-name entry.
class _DrawerMenuAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(_FakeAssistantRepository._capabilities);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    final now = DateTime.now();
    return TaskEither.right(<AssistantConversationSummary>[
      AssistantConversationSummary(
        id: 'titled',
        title: '已命名会话',
        status: 'active',
        lastMessageAt: now,
        createdAt: now,
        updatedAt: now,
      ),
      AssistantConversationSummary(
        id: 'untitled',
        title: null,
        status: 'active',
        lastMessageAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  final List<DailyRecordCreateInput> createdInputs = <DailyRecordCreateInput>[];

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) {
    createdInputs.add(input);
    return TaskEither.right(
      DailyRecordItem(
        id: 'record-created',
        kind: input.kind,
        occurredAt: input.occurredAt,
        title: input.title,
        value: input.value,
        unit: input.unit,
        note: input.note,
        payload: input.payload,
        createdAt: '2026-06-18T00:00:00Z',
        updatedAt: '2026-06-18T00:00:00Z',
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => TaskEither.right(
    const DailyRecordListData(items: <DailyRecordItem>[], total: 0),
  );

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      TaskEither.right(
        const DailyRecordSummaryData(summaries: <DailyRecordSummary>[]),
      );

  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();
}

/// Repository that hangs on both [getCapabilities] and [getLatestConversation]
/// until the completers finish. Used to test the loading skeleton state.
class _FullyHangingAssistantRepository
    with _ConfirmProposalsStub
    implements AssistantRepository {
  _FullyHangingAssistantRepository(
    this._pendingCapabilities,
    this._pendingConversation,
  );

  final Completer<AssistantCapabilities> _pendingCapabilities;
  final Completer<AssistantConversation?> _pendingConversation;

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(const <AssistantConversationSummary>[]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() {
    return TaskEither.tryCatch(
      () => _pendingConversation.future,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) {
    throw UnimplementedError();
  }

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() {
    return TaskEither.right(false);
  }

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.tryCatch(
      () => _pendingCapabilities.future,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}
