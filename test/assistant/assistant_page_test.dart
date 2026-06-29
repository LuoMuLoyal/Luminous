import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart'
    show
        AssistantContextSettingsDto,
        UpdateAssistantContextSettingsDto,
        UpdateUserSettingsDto,
        UserSettingsDataDto;
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/assistant/data/repositories/lucent_assistant_repository.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/pages/assistant_page.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
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
    expect(find.text('登录后才可以使用 AI 对话，并由你决定是否开放健康上下文。'), findsOneWidget);
    expect(find.byKey(const Key('assistant-input')), findsNothing);
  });

  testWidgets(
    'AI chat context toggle still works when settings are not loaded yet',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repository = _FakeAssistantRepository();
      final settingsController = _PendingUserSettingsController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              () => _SignedInAuthSessionNotifier(),
            ),
            assistantRepositoryProvider.overrideWithValue(repository),
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

      expect(
        find.byKey(const Key('assistant-row-context-health-profile')),
        findsOneWidget,
      );

      final pageScrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('assistant-row-context-health-profile')),
        240,
        scrollable: pageScrollable,
      );
      await tester.tap(
        find.byKey(const Key('assistant-row-context-health-profile')),
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
    final repository = _ErrorStreamAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    // Type and send a message
    final input = find.byKey(const Key('assistant-input'));
    expect(input, findsOneWidget);
    await tester.enterText(input, '帮我看看最近的睡眠');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
    await tester.pumpAndSettle();

    // Error message and retry button should be visible
    expect(find.text('这次回复没有完成'), findsOneWidget);
    expect(find.byKey(const Key('assistant-retry-action')), findsOneWidget);
    // Server error icon
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('assistant message shows usedTools as localized chips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _SuccessWithToolsAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    // Type and send a message
    final input = find.byKey(const Key('assistant-input'));
    await tester.enterText(input, '帮我看看最近的睡眠');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
    await tester.pumpAndSettle();

    // Localized tool chip should be visible
    expect(find.text('睡眠概况'), findsOneWidget);
  });

  testWidgets('assistant message shows proposal card', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _ProposalAssistantRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('assistant-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
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

  testWidgets('confirm create proposal writes daily record', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final dailyRecordRepository = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      _buildTestApp(
        repository: _ProposalAssistantRepository(),
        dailyRecordRepository: dailyRecordRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('assistant-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('assistant-proposal-confirm-proposal-create-1')),
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
        repository: _SettingsProposalAssistantRepository(),
        settingsController: settingsController,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('assistant-input')), '关闭记忆');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('assistant-proposal-confirm-proposal-settings-1')),
    );
    await tester.pumpAndSettle();

    expect(settingsController.lastPatchedSettings, isNotNull);
    expect(
      settingsController.lastPatchedSettings?.assistantMemoryEnabled,
      isFalse,
    );
    expect(find.text('已确认'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('dismiss proposal hides proposal card', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _buildTestApp(repository: _ProposalAssistantRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('assistant-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
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
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final dailyRecordRepository = _FakeDailyRecordRepository();

    await tester.pumpWidget(
      _buildTestApp(
        repository: _ExpiredProposalAssistantRepository(),
        dailyRecordRepository: dailyRecordRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('assistant-input')), '帮我记一杯水');
    await tester.tap(find.byKey(const Key('assistant-send-action')));
    await tester.pumpAndSettle();

    expect(find.text('这条建议已经过期，请重新生成后再确认。'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(
              const Key('assistant-proposal-confirm-proposal-create-expired'),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(dailyRecordRepository.createdInputs, isEmpty);
  });

  testWidgets('disabled AI chat shows hint about toggle above', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _DisabledAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('assistant-new-conversation-action')),
      findsOneWidget,
    );

    // Should show hint about toggling above
    expect(find.text('你已关闭 AI 对话，打开上方的“启用 AI 对话”开关即可恢复。'), findsOneWidget);
  });

  testWidgets('disabled AI chat still shows restored history', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _DisabledWithHistoryAssistantRepository();

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
    final repository = _RestoredConversationAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('昨晚睡得不太好'), findsOneWidget);
    expect(find.text('我看到你最近有睡眠记录，可以先从作息规律开始看。'), findsOneWidget);
  });

  testWidgets(
    'new conversation action archives latest conversation through repository',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repository = _RestoredConversationAssistantRepository();

      await tester.pumpWidget(_buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('assistant-new-conversation-action')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('assistant-input')),
        '这条输入会被清空',
      );
      await tester.tap(
        find.byKey(const Key('assistant-new-conversation-action')),
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
    final repository = _RetryAwareAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('assistant-input')),
      '帮我看看最近睡眠',
    );
    await tester.tap(find.byKey(const Key('assistant-send-action')));
    await tester.pumpAndSettle();

    expect(find.text('这次回复没有完成'), findsOneWidget);
    expect(find.text('帮我看看最近睡眠'), findsOneWidget);

    await tester.tap(find.byKey(const Key('assistant-retry-action')));
    await tester.pumpAndSettle();

    expect(repository.recordedMessageCounts, <int>[1, 1]);
    expect(find.text('帮我看看最近睡眠'), findsOneWidget);
    expect(find.text('先从最近三天入睡时间波动来看。'), findsOneWidget);
  });

  testWidgets('recent conversation sheet opens and switches conversation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _RecentConversationsAssistantRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('assistant-recent-conversations-action')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('assistant-recent-conversations-action')),
    );
    await tester.pumpAndSettle();

    expect(find.text('最近会话'), findsOneWidget);
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
  UpdateAssistantContextSettingsDto? lastContextUpdate;

  @override
  Future<UserSettingsDataDto> build() {
    return Completer<UserSettingsDataDto>().future;
  }

  @override
  Future<void> setAssistantContext(
    UpdateAssistantContextSettingsDto contextSettings,
  ) async {
    lastContextUpdate = contextSettings;
  }
}

class _FakeAssistantRepository implements AssistantRepository {
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
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async => _capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
    return const Stream<AssistantGenerationEvent>.empty();
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
  );
}

class _ReadyUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettingsDataDto> build() async {
    return UserSettingsDataDto(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: true,
      assistantMemoryEnabled: false,
      assistantContext: AssistantContextSettingsDto(
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

class _ErrorStreamAssistantRepository implements AssistantRepository {
  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
    return Stream<AssistantGenerationEvent>.error(
      const LucentApiException(message: '服务端出现问题', statusCode: 503),
    );
  }
}

class _SuccessWithToolsAssistantRepository implements AssistantRepository {
  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
    return Stream<AssistantGenerationEvent>.fromIterable([
      const AssistantGenerationChunkEvent('根据你的睡眠数据…'),
      AssistantGenerationResultEvent(
        conversationId: 'conversation-1',
        message: AssistantMessage(
          role: AssistantMessageRole.assistant,
          content: '你最近的睡眠质量不错，建议保持规律作息。',
          usedTools: const <String>['get_sleep_summary_by_range'],
          createdAt: DateTime.now(),
        ),
      ),
    ]);
  }
}

class _ProposalAssistantRepository implements AssistantRepository {
  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
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
                AssistantProposalPreviewField(label: '类型', value: 'water'),
              ],
              target: AssistantProposalTarget(
                kind: 'daily_record_draft',
                label: '2026-06-18 water 300 ml',
                matchedBy: <String>['relative_today'],
              ),
              constraints: <String>['必须先经过你确认，后端不会直接写入。'],
              expiresAt: DateTime.now().add(const Duration(minutes: 15)),
              payloadVersion: 1,
              payload: AssistantCreateDailyRecordProposalPayload(
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

class _SettingsProposalAssistantRepository implements AssistantRepository {
  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
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
                AssistantProposalPreviewField(label: '持久化记忆', value: '关闭'),
              ],
              target: AssistantProposalTarget(
                kind: 'user_settings',
                label: '助手设置',
                settingKeys: <String>['assistantMemoryEnabled'],
              ),
              constraints: <String>['必须先经过你确认，后端不会直接写入。'],
              expiresAt: DateTime.now().add(const Duration(minutes: 15)),
              payloadVersion: 1,
              payload: AssistantUpdateUserSettingsProposalPayload(
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

class _ExpiredProposalAssistantRepository implements AssistantRepository {
  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
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
                AssistantProposalPreviewField(label: '类型', value: 'water'),
              ],
              target: AssistantProposalTarget(
                kind: 'daily_record_draft',
                label: '2026-06-18 water 300 ml',
                matchedBy: <String>['relative_today'],
              ),
              constraints: <String>['必须先经过你确认，后端不会直接写入。'],
              expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
              payloadVersion: 1,
              payload: AssistantCreateDailyRecordProposalPayload(
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

class _DisabledAssistantRepository implements AssistantRepository {
  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async {
    return const AssistantCapabilities(
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
    );
  }

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _DisabledWithHistoryAssistantRepository
    extends _DisabledAssistantRepository {
  @override
  Future<AssistantConversation?> getLatestConversation() async {
    return AssistantConversation(
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
    );
  }
}

class _RestoredConversationAssistantRepository implements AssistantRepository {
  int clearCalls = 0;

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    return <AssistantConversationSummary>[
      AssistantConversationSummary(
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
  Future<AssistantConversation?> getLatestConversation() async {
    return AssistantConversation(
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
    );
  }

  @override
  Future<AssistantConversation> openConversation(String conversationId) async {
    return (await getLatestConversation())!;
  }

  @override
  Future<bool> clearLatestConversation() async {
    clearCalls += 1;
    return true;
  }

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
    return const Stream<AssistantGenerationEvent>.empty();
  }
}

class _RetryAwareAssistantRepository implements AssistantRepository {
  _RetryAwareAssistantRepository();

  final List<int> recordedMessageCounts = <int>[];
  int _attempt = 0;

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async =>
      const <AssistantConversationSummary>[];

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<AssistantConversation> openConversation(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) async* {
    recordedMessageCounts.add(messages.length);
    _attempt += 1;

    if (_attempt == 1) {
      throw const LucentApiException(message: '服务端出现问题', statusCode: 503);
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

class _RecentConversationsAssistantRepository implements AssistantRepository {
  final List<String> openedConversationIds = <String>[];

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    return <AssistantConversationSummary>[
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
    ];
  }

  @override
  Future<AssistantConversation?> getLatestConversation() async {
    return AssistantConversation(
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
    );
  }

  @override
  Future<AssistantConversation> openConversation(String conversationId) async {
    openedConversationIds.add(conversationId);
    return AssistantConversation(
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
    );
  }

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AssistantCapabilities> getCapabilities() async =>
      _FakeAssistantRepository._capabilities;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  ) {
    return const Stream<AssistantGenerationEvent>.empty();
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
