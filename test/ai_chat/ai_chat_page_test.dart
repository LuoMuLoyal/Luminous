import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
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
  testWidgets('AI chat page shows sign-in gate when signed out', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => _SignedOutAuthSessionNotifier()),
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
            initialLocation: '/settings/ai-chat',
            routes: [
              GoRoute(
                path: '/settings/ai-chat',
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
            authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
            aiChatRepositoryProvider.overrideWithValue(repository),
            userSettingsControllerProvider.overrideWith(() => settingsController),
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
              initialLocation: '/settings/ai-chat',
              routes: [
                GoRoute(
                  path: '/settings/ai-chat',
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

      expect(find.byKey(const Key('ai-chat-row-context-health-profile')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ai-chat-row-context-health-profile')));
      await tester.pumpAndSettle();

      expect(settingsController.lastContextUpdate, isNotNull);
      expect(settingsController.lastContextUpdate?.healthProfile, isFalse);
      expect(settingsController.lastContextUpdate?.dailyRecords, isTrue);
      expect(settingsController.lastContextUpdate?.sleepRecords, isTrue);
      expect(settingsController.lastContextUpdate?.currentMedicines, isTrue);
    },
  );
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
  Future<AiChatCapabilities> getCapabilities() async => _capabilities;

  @override
  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages) {
    return const Stream<AiChatGenerationEvent>.empty();
  }
}
