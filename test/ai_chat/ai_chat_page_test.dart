import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/ai_chat/data/repositories/lucent_ai_chat_repository.dart';
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';
import 'package:luminous/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
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

  testWidgets('disabled AI chat shows hint about toggle above', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _DisabledAiChatRepository();

    await tester.pumpWidget(_buildTestApp(repository: repository));
    await tester.pumpAndSettle();

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
    'clear conversation archives latest conversation through repository',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repository = _RestoredConversationAiChatRepository();

      await tester.pumpWidget(_buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai-chat-clear-action')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ai-chat-clear-action')));
      await tester.pumpAndSettle();

      expect(repository.clearCalls, 1);
      expect(find.text('昨晚睡得不太好'), findsNothing);
      expect(find.text('开始第一条消息'), findsOneWidget);
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
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async => _capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return const Stream<AiChatGenerationEvent>.empty();
  }
}

Widget _buildTestApp({required AiChatRepository repository}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
      aiChatRepositoryProvider.overrideWithValue(repository),
      userSettingsControllerProvider.overrideWith(
        () => _ReadyUserSettingsController(),
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

class _ErrorStreamAiChatRepository implements AiChatRepository {
  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

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
  Future<AiChatConversation?> getLatestConversation() async => null;

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
          usedTools: const <String>['recent_sleep_summary'],
          createdAt: DateTime.now(),
        ),
      ),
    ]);
  }
}

class _DisabledAiChatRepository implements AiChatRepository {
  @override
  Future<AiChatConversation?> getLatestConversation() async => null;

  @override
  Future<bool> clearLatestConversation() async => false;

  @override
  Future<AiChatCapabilities> getCapabilities() async {
    return const AiChatCapabilities(
      phase: 'phase_1',
      aiChatEnabled: false,
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
          usedTools: const <String>['recent_sleep_summary'],
        ),
      ],
      lastMessageAt: DateTime.parse('2026-06-18T01:01:00Z'),
      createdAt: DateTime.parse('2026-06-18T01:00:00Z'),
      updatedAt: DateTime.parse('2026-06-18T01:01:00Z'),
    );
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
  Future<AiChatConversation?> getLatestConversation() async => null;

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
