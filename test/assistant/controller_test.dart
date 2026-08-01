import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';

/// A fake repository with canned responses.
class _FakeAssistantRepository implements AssistantRepository {
  _FakeAssistantRepository({this.latestConversation, this.streamOverride});

  final AssistantConversation? latestConversation;
  final Stream<AssistantGenerationEvent>? streamOverride;

  String? lastStreamConversationId;

  @override
  Future<AssistantCapabilities> getCapabilities() async {
    return AssistantCapabilities(
      phase: 'production',
      assistantEnabled: true,
      assistantMemoryEnabled: true,
      assistantContext: const AssistantContextAccess(
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
      ragEnabled: true,
      tools: const <AssistantToolCapability>[],
      updatedAt: DateTime(2026, 6, 10),
    );
  }

  @override
  Future<AssistantConversation?> getLatestConversation() async {
    return latestConversation;
  }

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    return const <AssistantConversationSummary>[];
  }

  @override
  Future<AssistantConversation> openConversation(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => true;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) {
    lastStreamConversationId = conversationId;
    return streamOverride ?? const Stream.empty();
  }

  @override
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) async {
    return null;
  }
}

void main() {
  group('AssistantController', () {
    test('build returns loading state when authenticated', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isTrue);
    });

    test('loadCapabilities populates capabilities on success', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isFalse);
      expect(state.capabilities, isNotNull);
      expect(state.capabilities!.chatModelConfigured, isTrue);
    });

    test('loadCapabilities handles error gracefully', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            _ErrorThrowingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isFalse);
      expect(state.capabilityError, isNotNull);
    });

    test('sendMessage forwards the persisted conversation id', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final fake = _FakeAssistantRepository(
        latestConversation: AssistantConversation(
          id: 'persisted-1',
          title: null,
          status: 'active',
          messages: const <AssistantMessage>[],
          lastMessageAt: null,
          createdAt: DateTime(2026, 6, 1),
          updatedAt: DateTime(2026, 6, 1),
        ),
        streamOverride: Stream.fromIterable([
          AssistantGenerationResultEvent(
            conversationId: 'persisted-1',
            message: AssistantMessage(
              role: AssistantMessageRole.assistant,
              content: 'ok',
              createdAt: DateTime(2026, 6, 1),
            ),
          ),
        ]),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadLatestConversation();
      await controller.sendMessage('hello');

      expect(fake.lastStreamConversationId, 'persisted-1');
    });
  });
}

class _ErrorThrowingRepository implements AssistantRepository {
  @override
  Future<AssistantCapabilities> getCapabilities() async {
    throw Exception('Network error');
  }

  @override
  Future<AssistantConversation?> getLatestConversation() async => null;

  @override
  Future<List<AssistantConversationSummary>> listRecentConversations() async {
    return const <AssistantConversationSummary>[];
  }

  @override
  Future<AssistantConversation> openConversation(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearLatestConversation() async => true;

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) async* {
    // no-op
  }

  @override
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) async {
    throw UnimplementedError();
  }
}
