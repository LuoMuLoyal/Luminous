import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/assistant/data/repositories/lucent_assistant_repository.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_test_helpers.dart';

/// A fake repository with canned responses.
class _FakeAssistantRepository implements AssistantRepository {
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
    List<AssistantMessage> messages,
  ) async* {
    // no-op
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
    List<AssistantMessage> messages,
  ) async* {
    // no-op
  }
}
