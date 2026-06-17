import 'package:flutter/foundation.dart';

@immutable
class AiChatContextPermissions {
  const AiChatContextPermissions({
    required this.healthProfile,
    required this.dailyRecords,
    required this.sleepRecords,
    required this.currentMedicines,
  });

  final bool healthProfile;
  final bool dailyRecords;
  final bool sleepRecords;
  final bool currentMedicines;

  int get enabledCount => <bool>[
    healthProfile,
    dailyRecords,
    sleepRecords,
    currentMedicines,
  ].where((value) => value).length;
}

@immutable
class AiChatToolCapability {
  const AiChatToolCapability({
    required this.id,
    required this.requiredContextSources,
    required this.permittedByUser,
    required this.enabled,
    required this.implemented,
    required this.disabledReason,
  });

  final String id;
  final List<String> requiredContextSources;
  final bool permittedByUser;
  final bool enabled;
  final bool implemented;
  final String? disabledReason;
}

@immutable
class AiChatCapabilities {
  const AiChatCapabilities({
    required this.phase,
    required this.aiChatEnabled,
    required this.aiChatContext,
    required this.chatModelConfigured,
    required this.interactiveChatReady,
    required this.langGraphReady,
    required this.streamingSupported,
    required this.streamingTransport,
    required this.markdownRenderingRecommended,
    required this.ragEnabled,
    required this.tools,
    required this.updatedAt,
  });

  final String phase;
  final bool aiChatEnabled;
  final AiChatContextPermissions aiChatContext;
  final bool chatModelConfigured;
  final bool interactiveChatReady;
  final bool langGraphReady;
  final bool streamingSupported;
  final String streamingTransport;
  final bool markdownRenderingRecommended;
  final bool ragEnabled;
  final List<AiChatToolCapability> tools;
  final DateTime? updatedAt;

  bool get canSendMessages =>
      aiChatEnabled &&
      chatModelConfigured &&
      interactiveChatReady &&
      streamingSupported;

  int get enabledToolCount => tools.where((tool) => tool.enabled).length;
}

enum AiChatMessageRole { user, assistant }

@immutable
class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.content,
    required this.createdAt,
    this.usedTools = const <String>[],
  });

  final AiChatMessageRole role;
  final String content;
  final DateTime createdAt;
  final List<String> usedTools;
}
