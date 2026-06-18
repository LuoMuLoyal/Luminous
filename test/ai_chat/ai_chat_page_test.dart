import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart'
    show
        AiChatContextSettingsDto,
        UpdateAiChatContextSettingsDto,
        UpdateUserSettingsDto,
        UserSettingsDataDto;
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/ai_chat/data/repositories/lucent_ai_chat_repository.dart';
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';
import 'package:luminous/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AI chat page shows sign-in gate when signed out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/assistant',
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AiChatPage(),
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
    expect(find.text('登录后才可以使用 AI 对话，并由你决定是否开放健康上下文。'), findsOneWidget);
    expect(find.byKey(const Key('ai-chat-input')), findsNothing);
  });

  testWidgets(
    'AI chat context toggle still works when settings are not loaded yet',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repository = _FakeAiChatRepository();
      final settingsController = _PendingUserSettingsController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              () => _SignedInAuthSessionNotifier(),
            ),
            aiChatRepositoryProvider.overrideWithValue(repository),
            userSettingsControllerProvider.overrideWith(
              () => settingsController,
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: const Locale('zh'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/assistant',
              routes: [
                GoRoute(
                  path: '/assistant',
                  builder: (context, state) => const AiChatPage(),
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

      expect(
        find.byKey(const Key('ai-chat-row-context-health-profile')),
        findsOneWidget,
      );

      final pageScrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('ai-chat-row-context-health-profile')),
        240,
        scrollable: pageScrollable,
      );
      await tester.tap(
        find.byKey(const Key('ai-chat-row-context-health-profile')),
      );
      await tester.pumpAndSettle();

      expect(settingsController.lastContextUpdate, isNotNull);
      expect(settingsController.lastContextUpdate?.healthProfile, isFalse);
      expect(settingsController.lastContextUpdate?.dailyRecords, isTrue);
      expect(settingsController.lastContextUpdate?.sleepRecords, isTrue);
      expect(settingsController.lastContextUpdate?.currentMedicines, isTrue);
    },
  );

  testWidgets('send error shows retry button and error-specific icon', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _ErrorStreamAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    // Type and send a message
    final input = find.byKey(const Key('ai-chat-input'));
    expect(input, findsOneWidget);
    await tester.enterText(input, '帮我看看最近的睡眠');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    // Error message and retry button should be visible
    expect(find.text('这次回复没有完成'), findsOneWidget);
    expect(find.byKey(const Key('ai-chat-retry-action')), findsOneWidget);
    // Server error icon
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('assistant message shows usedTools as localized chips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _SuccessWithToolsAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    // Type and send a message
    final input = find.byKey(const Key('ai-chat-input'));
    await tester.enterText(input, '帮我看看最近的睡眠');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    // Localized tool chip should be visible
    expect(find.text('睡眠概况'), findsOneWidget);
  });

  testWidgets('assistant message shows proposal card', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _ProposalAiChatRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-chat-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    expect(find.text('保存这条记录'), findsOneWidget);
    expect(find.text('确认保存'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('类型: water'), findsOneWidget);
  });

  testWidgets('confirm create proposal writes daily record', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final dailyRecordRepository = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      _buildTestApp(
        repository: _ProposalAiChatRepository(),
        dailyRecordRepository: dailyRecordRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-chat-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('ai-chat-proposal-confirm-proposal-create-1')),
    );
    await tester.pumpAndSettle();

    expect(dailyRecordRepository.createdInputs, hasLength(1));
    expect(
      dailyRecordRepository.createdInputs.single.kind,
      DailyRecordKind.water,
    );
    expect(dailyRecordRepository.createdInputs.single.value, '300');
    expect(find.text('已确认'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('confirm settings proposal patches user settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final settingsController = _TrackingUserSettingsController();

    await tester.pumpWidget(
      _buildTestApp(
        repository: _SettingsProposalAiChatRepository(),
        settingsController: settingsController,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-chat-input')), '关闭记忆');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('ai-chat-proposal-confirm-proposal-settings-1')),
    );
    await tester.pumpAndSettle();

    expect(settingsController.lastPatchedSettings, isNotNull);
    expect(
      settingsController.lastPatchedSettings?.aiChatMemoryEnabled,
      isFalse,
    );
    expect(find.text('已确认'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('dismiss proposal hides proposal card', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _ProposalAiChatRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-chat-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    expect(find.text('保存这条记录'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('ai-chat-proposal-dismiss-proposal-create-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('保存这条记录'), findsNothing);
  });

  testWidgets('disabled AI chat shows hint about toggle above', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _DisabledAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('ai-chat-new-conversation-action')),
      findsOneWidget,
    );

    // Should show hint about toggling above
    expect(find.text('你已关闭 AI 对话，打开上方的“启用 AI 对话”开关即可恢复。'), findsOneWidget);
  });

  testWidgets('disabled AI chat still shows restored history', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _DisabledWithHistoryAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('之前那次睡眠为什么这么差？'), findsOneWidget);
    expect(find.text('我先结合你最近几天的睡眠记录来解释。'), findsOneWidget);
    expect(find.text('你已关闭 AI 对话，打开上方的“启用 AI 对话”开关即可恢复。'), findsNothing);
  });

  testWidgets('latest persisted conversation is restored on assistant page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _RestoredConversationAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('昨晚睡得不太好'), findsOneWidget);
    expect(find.text('我看到你最近有睡眠记录，可以先从作息规律开始看。'), findsOneWidget);
  });

  testWidgets(
    'new conversation action archives latest conversation through repository',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repository = _RestoredConversationAiChatRepository();

      await tester.pumpWidget(_buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('ai-chat-new-conversation-action')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('ai-chat-input')),
        '这条输入会被清空',
      );
      await tester.tap(
        find.byKey(const Key('ai-chat-new-conversation-action')),
      );
      await tester.pumpAndSettle();

      expect(repository.clearCalls, 1);
      expect(find.text('昨晚睡得不太好'), findsNothing);
      expect(find.text('开始第一条消息'), findsOneWidget);
      expect(find.text('这条输入会被清空'), findsNothing);
    },
  );

  testWidgets('retry does not duplicate failed user message', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _RetryAwareAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-chat-input')), '帮我看看最近睡眠');
    await tester.tap(find.byKey(const Key('ai-chat-send-action')));
    await tester.pumpAndSettle();

    expect(find.text('这次回复没有完成'), findsOneWidget);
    expect(find.text('帮我看看最近睡眠'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-chat-retry-action')));
    await tester.pumpAndSettle();

    expect(repository.recordedMessageCounts, <int>[1, 1]);
    expect(find.text('帮我看看最近睡眠'), findsOneWidget);
    expect(find.text('先从最近三天入睡时间波动来看。'), findsOneWidget);
  });

  testWidgets('recent conversation sheet opens and switches conversation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _RecentConversationsAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('ai-chat-recent-conversations-action')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('ai-chat-recent-conversations-action')),
    );
    await tester.pumpAndSettle();

    expect(find.text('最近会话'), findsOneWidget);
    expect(find.text('睡眠跟进'), findsOneWidget);
    expect(find.text('头痛追踪'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const Key('ai-chat-recent-conversation-conversation-headache'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.openedConversationIds, <String>['conversation-headache']);
    expect(find.text('今天头痛还在继续'), findsOneWidget);
    expect(find.text('先看一下你最近记录里的触发因素。'), findsOneWidget);
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

class _PendingUserSettingsController extends UserSettingsController {
  UpdateAiChatContextSettingsDto? lastContextUpdate;

  @override
  Future<UserSettingsDataDto> build() {
    return Completer<UserSettingsDataDto>().future;
  }

  @override
  Future<void> setAiChatContext(
    UpdateAiChatContextSettingsDto contextSettings,
  ) async {
    lastContextUpdate = contextSettings;
  }
}

class _FakeAiChatRepository implements AiChatRepository {
  static const _capabilities = AiChatCapabilities(
    phase: 'phase_1',
    aiChatEnabled: true,
    aiChatMemoryEnabled: false,
    aiChatContext: AiChatContextPermissions(
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
    tools: <AiChatToolCapability>[],
    updatedAt: null,
  );

  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async => _capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return const Stream<AiChatGenerationEvent>.empty();
  }
}

Widget _buildTestApp({
  required AiChatRepository repository,
  DailyRecordRepository? dailyRecordRepository,
  UserSettingsController? settingsController,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
      aiChatRepositoryProvider.overrideWithValue(repository),
      dailyRecordRepositoryProvider.overrideWithValue(
        dailyRecordRepository ?? _FakeDailyRecordRepository(),
      ),
      userSettingsControllerProvider.overrideWith(
        () => settingsController ?? _ReadyUserSettingsController(),
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('zh'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/assistant',
        routes: [
          GoRoute(
            path: '/assistant',
            builder: (context, state) => const AiChatPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('login-page')),
          ),
        ],
      ),
    ),
  );
}

class _ReadyUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettingsDataDto> build() async {
    return UserSettingsDataDto(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      aiChatEnabled: true,
      aiChatMemoryEnabled: false,
      aiChatContext: AiChatContextSettingsDto(
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
  UpdateUserSettingsDto? lastPatchedSettings;

  @override
  Future<void> applySettingsPatch(UpdateUserSettingsDto dto) async {
    lastPatchedSettings = dto;
  }
}

class _ErrorStreamAiChatRepository implements AiChatRepository {
  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return Stream<AiChatGenerationEvent>.error(
      const LucentApiException(message: '服务端出现问题', statusCode: 503),
    );
  }
}

class _SuccessWithToolsAiChatRepository implements AiChatRepository {
  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return Stream<AiChatGenerationEvent>.fromIterable([
      const AiChatGenerationChunkEvent('根据你的睡眠数据…'),
      AiChatGenerationResultEvent(
        conversationId: 'conversation-1',
        message: AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '你最近的睡眠质量不错，建议保持规律作息。',
          usedTools: const <String>['get_sleep_summary_by_range'],
          createdAt: DateTime.now(),
        ),
      ),
    ]);
  }
}

class _ProposalAiChatRepository implements AiChatRepository {
  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return Stream<AiChatGenerationEvent>.fromIterable([
      AiChatGenerationResultEvent(
        conversationId: 'conversation-proposal',
        message: AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '我已经整理成一条可确认的记录建议。',
          createdAt: DateTime.parse('2026-06-18T03:00:00Z'),
          proposedActions: const <AiChatProposedAction>[
            AiChatProposedAction(
              id: 'proposal-create-1',
              type: AiChatProposedActionType.createDailyRecord,
              title: '保存这条记录',
              summary: '准备保存一条 2026-06-18 的 water 记录。',
              reason: 'Detected water intake.',
              previewFields: <AiChatProposalPreviewField>[
                AiChatProposalPreviewField(label: '类型', value: 'water'),
              ],
              payloadVersion: 1,
              payload: AiChatCreateDailyRecordProposalPayload(
                draft: AiChatCreateDailyRecordDraft(
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

class _SettingsProposalAiChatRepository implements AiChatRepository {
  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return Stream<AiChatGenerationEvent>.fromIterable([
      AiChatGenerationResultEvent(
        conversationId: 'conversation-settings-proposal',
        message: AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '我整理出了一组设置变更。',
          createdAt: DateTime.parse('2026-06-18T03:30:00Z'),
          proposedActions: const <AiChatProposedAction>[
            AiChatProposedAction(
              id: 'proposal-settings-1',
              type: AiChatProposedActionType.updateUserSettings,
              title: '更新助手相关设置',
              summary: '我整理出了一组设置变更，确认后才会真正写入。',
              reason: null,
              previewFields: <AiChatProposalPreviewField>[
                AiChatProposalPreviewField(label: '持久化记忆', value: '关闭'),
              ],
              payloadVersion: 1,
              payload: AiChatUpdateUserSettingsProposalPayload(
                draft: AiChatUpdateUserSettingsDraft(
                  aiChatMemoryEnabled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _DisabledAiChatRepository implements AiChatRepository {
  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async {
    return const AiChatCapabilities(
      phase: 'phase_1',
      aiChatEnabled: false,
      aiChatMemoryEnabled: false,
      aiChatContext: AiChatContextPermissions(
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
      tools: <AiChatToolCapability>[],
      updatedAt: null,
    );
  }

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return const Stream<AiChatGenerationEvent>.empty();
  }
}

class _DisabledWithHistoryAiChatRepository extends _DisabledAiChatRepository {
  @override
  Future<AiChatConversation?> getLatestConversation() async {
    return AiChatConversation(
      id: 'conversation-disabled-history',
      title: '睡眠复盘',
      status: 'active',
      messages: <AiChatMessage>[
        AiChatMessage(
          role: AiChatMessageRole.user,
          content: '之前那次睡眠为什么这么差？',
          createdAt: DateTime.parse('2026-06-18T02:00:00Z'),
        ),
        AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '我先结合你最近几天的睡眠记录来解释。',
          createdAt: DateTime.parse('2026-06-18T02:01:00Z'),
        ),
      ],
      lastMessageAt: DateTime.parse('2026-06-18T02:01:00Z'),
      createdAt: DateTime.parse('2026-06-18T02:00:00Z'),
      updatedAt: DateTime.parse('2026-06-18T02:01:00Z'),
    );
  }
}

class _RestoredConversationAiChatRepository implements AiChatRepository {
  int clearCalls = 0;

  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async {
    return <AiChatConversationSummary>[
      AiChatConversationSummary(
        id: 'conversation-restored',
        title: '睡眠跟进',
        status: 'active',
        lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
      ),
    ];
  }

  @override
  Future<AiChatConversation?> getLatestConversation() async {
    return AiChatConversation(
      id: 'conversation-restored',
      title: '睡眠跟进',
      status: 'active',
      messages: <AiChatMessage>[
        AiChatMessage(
          role: AiChatMessageRole.user,
          content: '昨晚睡得不太好',
          createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        ),
        AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '我看到你最近有睡眠记录，可以先从作息规律开始看。',
          createdAt: DateTime.parse('2026-06-18T01:01:00Z'),
          usedTools: const <String>['get_sleep_summary_by_range'],
        ),
      ],
      lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
      createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
      updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
    );
  }

  @override
  Future<AiChatConversation> openConversation(String conversationId) async {
    return (await getLatestConversation())!;
  }

  @override
  Future<bool> clearLatestConversation() async {
    clearCalls += 1;
    return true;
  }

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return const Stream<AiChatGenerationEvent>.empty();
  }
}

class _RetryAwareAiChatRepository implements AiChatRepository {
  _RetryAwareAiChatRepository();

  final List<int> recordedMessageCounts = <int>[];
  int _attempt = 0;

  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async =>
      const <AiChatConversationSummary>[];

  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<AiChatConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(
    List<AiChatMessage> messages,
  ) async* {
    recordedMessageCounts.add(messages.length);
    _attempt += 1;

    if (_attempt == 1) {
      throw const LucentApiException(message: '服务端出现问题', statusCode: 503);
    }

    yield const AiChatGenerationChunkEvent('先从最近三天入睡时间波动来看。');
    yield AiChatGenerationResultEvent(
      conversationId: 'conversation-retry',
      message: AiChatMessage(
        role: AiChatMessageRole.assistant,
        content: '先从最近三天入睡时间波动来看。',
        createdAt: DateTime.now(),
      ),
    );
  }
}

class _RecentConversationsAiChatRepository implements AiChatRepository {
  final List<String> openedConversationIds = <String>[];

  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async {
    return <AiChatConversationSummary>[
      AiChatConversationSummary(
        id: 'conversation-restored',
        title: '睡眠跟进',
        status: 'active',
        lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
        createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
      ),
      AiChatConversationSummary(
        id: 'conversation-headache',
        title: '头痛追踪',
        status: 'archived',
        lastMessageAt: DateTime.parse('2026-06-17T09:01:00Z'),
        createdAt: DateTime.parse('2026-06-17T09:00:00Z'),
        updatedAt: DateTime.parse('2026-06-17T09:01:00Z'),
      ),
    ];
  }

  @override
  Future<AiChatConversation?> getLatestConversation() async {
    return AiChatConversation(
      id: 'conversation-restored',
      title: '睡眠跟进',
      status: 'active',
      messages: <AiChatMessage>[
        AiChatMessage(
          role: AiChatMessageRole.user,
          content: '昨晚睡得不太好',
          createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
        ),
        AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '我看到你最近有睡眠记录，可以先从作息规律开始看。',
          createdAt: DateTime.parse('2026-06-18T01:01:00Z'),
        ),
      ],
      lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
      createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
      updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
    );
  }

  @override
  Future<AiChatConversation> openConversation(String conversationId) async {
    openedConversationIds.add(conversationId);
    return AiChatConversation(
      id: 'conversation-headache',
      title: '头痛追踪',
      status: 'active',
      messages: <AiChatMessage>[
        AiChatMessage(
          role: AiChatMessageRole.user,
          content: '今天头痛还在继续',
          createdAt: DateTime.parse('2026-06-17T09:00:00Z'),
        ),
        AiChatMessage(
          role: AiChatMessageRole.assistant,
          content: '先看一下你最近记录里的触发因素。',
          createdAt: DateTime.parse('2026-06-17T09:01:00Z'),
        ),
      ],
      lastMessageAt: DateTime.parse('2026-06-17T09:01:00Z'),
      createdAt: DateTime.parse('2026-06-17T09:00:00Z'),
      updatedAt: DateTime.parse('2026-06-17T09:01:00Z'),
    );
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async =>
      _FakeAiChatRepository._capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return const Stream<AiChatGenerationEvent>.empty();
  }
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  final List<DailyRecordCreateInput> createdInputs = <DailyRecordCreateInput>[];

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    createdInputs.add(input);
    return DailyRecordItem(
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
    );
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async => const DailyRecordListData(items: <DailyRecordItem>[], total: 0);

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async =>
      const DailyRecordSummaryData(summaries: <DailyRecordSummary>[]);

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> get(String id) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> update(String id, DailyRecordUpdateInput input) {
    throw UnimplementedError();
  }
}
