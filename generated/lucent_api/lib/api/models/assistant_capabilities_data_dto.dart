// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_context_settings_dto.dart';
import 'assistant_tool_capability_dto.dart';

part 'assistant_capabilities_data_dto.g.dart';

@JsonSerializable()
class AssistantCapabilitiesDataDto {
  const AssistantCapabilitiesDataDto({
    required this.phase,
    required this.assistantEnabled,
    required this.assistantMemoryEnabled,
    required this.assistantContext,
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

  factory AssistantCapabilitiesDataDto.fromJson(Map<String, Object?> json) =>
      _$AssistantCapabilitiesDataDtoFromJson(json);

  /// Current backend rollout phase for the assistant.
  final String phase;

  /// Whether the user has left the assistant enabled in settings.
  final bool assistantEnabled;

  /// Whether cross-conversation assistant memory reuse is enabled for this user.
  final bool assistantMemoryEnabled;

  /// Fine-grained assistant context permissions from user settings.
  final AssistantContextSettingsDto assistantContext;

  /// Whether the configured chat model role exists server-side.
  final bool chatModelConfigured;

  /// Whether an actual end-user chat interaction route is ready to be exposed.
  final bool interactiveChatReady;

  /// Whether the LangGraph orchestration foundation is active.
  final bool langGraphReady;

  /// Whether the current backend intends to stream responses.
  final bool streamingSupported;

  /// Recommended streaming transport for the current chat contract.
  final String streamingTransport;

  /// Whether the frontend should expect Markdown output and render it faithfully.
  final bool markdownRenderingRecommended;

  /// Whether medicine-leaflet retrieval augmentation is currently enabled.
  final bool ragEnabled;

  /// Tool-by-tool capability breakdown after combining system state and user permissions.
  final List<AssistantToolCapabilityDto> tools;

  /// ISO-8601 timestamp of the latest related settings update.
  final String? updatedAt;

  Map<String, Object?> toJson() => _$AssistantCapabilitiesDataDtoToJson(this);
}
