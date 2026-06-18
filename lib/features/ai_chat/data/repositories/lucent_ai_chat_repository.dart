import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/ai_chat/data/datasources/ai_chat_remote_data_source.dart';
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';

sealed class AiChatGenerationEvent {
  const AiChatGenerationEvent();
}

class AiChatGenerationChunkEvent extends AiChatGenerationEvent {
  const AiChatGenerationChunkEvent(this.content);

  final String content;
}

class AiChatGenerationResultEvent extends AiChatGenerationEvent {
  const AiChatGenerationResultEvent({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final AiChatMessage message;
}

abstract interface class AiChatRepository {
  Future<AiChatCapabilities> getCapabilities();

  Future<List<AiChatConversationSummary>> listRecentConversations();

  Future<AiChatConversation?> getLatestConversation();

  Future<AiChatConversation> openConversation(String conversationId);

  Future<bool> clearLatestConversation();

  Stream<AiChatGenerationEvent> streamMessages(List<AiChatMessage> messages);
}

final aiChatRemoteDataSourceProvider = Provider<AiChatRemoteDataSource>((ref) {
  final api = ref.watch(lucentAiChatApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return AiChatRemoteDataSource(api: api, dio: dio);
});

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final dataSource = ref.watch(aiChatRemoteDataSourceProvider);
  return LucentAiChatRepository(dataSource: dataSource);
});

class LucentAiChatRepository implements AiChatRepository {
  LucentAiChatRepository({required this.dataSource});

  final AiChatRemoteDataSource dataSource;

  @override
  Future<AiChatCapabilities> getCapabilities() async {
    final dto = await dataSource.getCapabilities();
    return _mapCapabilities(dto);
  }

  @override
  Future<AiChatConversation?> getLatestConversation() async {
    final dto = await dataSource.getLatestConversation();
    if (dto == null) {
      return null;
    }
    return _mapConversation(dto);
  }

  @override
  Future<List<AiChatConversationSummary>> listRecentConversations() async {
    final items = await dataSource.listRecentConversations();
    return items.map(_mapConversationSummary).toList(growable: false);
  }

  @override
  Future<AiChatConversation> openConversation(String conversationId) async {
    final dto = await dataSource.openConversation(conversationId);
    return _mapConversation(dto);
  }

  @override
  Future<bool> clearLatestConversation() {
    return dataSource.clearLatestConversation();
  }

  @override
  Stream<AiChatGenerationEvent> streamMessages(
    List<AiChatMessage> messages,
  ) async* {
    final requestMessages = messages
        .map(
          (message) => lucent.AiChatInputMessageDto(
            role: switch (message.role) {
              AiChatMessageRole.user =>
                lucent.AiChatInputMessageDtoRoleEnum.user,
              AiChatMessageRole.assistant =>
                lucent.AiChatInputMessageDtoRoleEnum.assistant,
            },
            content: message.content,
          ),
        )
        .toList(growable: false);

    await for (final event in dataSource.streamMessages(
      messages: requestMessages,
    )) {
      switch (event) {
        case AiChatRemoteChunkEvent():
          yield AiChatGenerationChunkEvent(event.content);
        case AiChatRemoteResultEvent():
          yield AiChatGenerationResultEvent(
            conversationId: event.conversationId,
            message: AiChatMessage(
              role: AiChatMessageRole.assistant,
              content: event.content,
              usedTools: event.usedTools,
              createdAt: event.generatedAt,
            ),
          );
      }
    }
  }

  AiChatCapabilities _mapCapabilities(lucent.AiChatCapabilitiesDataDto dto) {
    return AiChatCapabilities(
      phase: dto.phase,
      aiChatEnabled: dto.aiChatEnabled,
      aiChatMemoryEnabled: dto.aiChatMemoryEnabled,
      aiChatContext: AiChatContextPermissions(
        healthProfile: dto.aiChatContext.healthProfile,
        dailyRecords: dto.aiChatContext.dailyRecords,
        sleepRecords: dto.aiChatContext.sleepRecords,
        currentMedicines: dto.aiChatContext.currentMedicines,
      ),
      chatModelConfigured: dto.chatModelConfigured,
      interactiveChatReady: dto.interactiveChatReady,
      langGraphReady: dto.langGraphReady,
      streamingSupported: dto.streamingSupported,
      streamingTransport: dto.streamingTransport,
      markdownRenderingRecommended: dto.markdownRenderingRecommended,
      ragEnabled: dto.ragEnabled,
      tools: dto.tools
          .map(
            (tool) => AiChatToolCapability(
              id: tool.name.value,
              requiredContextSources: tool.requiredContextSources,
              permittedByUser: tool.permittedByUser,
              enabled: tool.enabled,
              implemented: tool.implemented,
              disabledReason: tool.disabledReason?.value,
            ),
          )
          .toList(growable: false),
      updatedAt: DateTime.tryParse(dto.updatedAt ?? ''),
    );
  }

  AiChatConversation _mapConversation(lucent.AiChatConversationDataDto dto) {
    return AiChatConversation(
      id: dto.id,
      title: dto.title?.toString(),
      status: dto.status.value,
      messages: dto.messages
          .map(_mapConversationMessage)
          .toList(growable: false),
      lastMessageAt: _parseDateTime(dto.lastMessageAt),
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? DateTime.now(),
    );
  }

  AiChatConversationSummary _mapConversationSummary(
    lucent.AiChatConversationSummaryDto dto,
  ) {
    return AiChatConversationSummary(
      id: dto.id,
      title: dto.title?.toString(),
      status: dto.status.value,
      lastMessageAt: _parseDateTime(dto.lastMessageAt),
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(dto.updatedAt) ?? DateTime.now(),
    );
  }

  AiChatMessage _mapConversationMessage(
    lucent.AiChatConversationMessageDto dto,
  ) {
    return AiChatMessage(
      role: switch (dto.role) {
        lucent.AiChatConversationMessageDtoRoleEnum.user =>
          AiChatMessageRole.user,
        lucent.AiChatConversationMessageDtoRoleEnum.assistant =>
          AiChatMessageRole.assistant,
        lucent.AiChatConversationMessageDtoRoleEnum.unknownDefaultOpenApi =>
          AiChatMessageRole.assistant,
      },
      content: dto.content,
      createdAt: _parseDateTime(dto.createdAt) ?? DateTime.now(),
      usedTools: dto.usedTools,
    );
  }

  DateTime? _parseDateTime(Object? raw) {
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw.toString());
  }
}
