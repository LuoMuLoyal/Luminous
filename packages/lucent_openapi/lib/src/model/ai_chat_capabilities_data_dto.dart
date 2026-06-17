//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/ai_chat_context_settings_dto.dart';
import 'package:lucent_openapi/src/model/ai_chat_tool_capability_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_capabilities_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatCapabilitiesDataDto {
  /// Returns a new [AiChatCapabilitiesDataDto] instance.
  AiChatCapabilitiesDataDto({
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

  /// Current backend rollout phase for AI chat.
  @JsonKey(name: r'phase', required: true, includeIfNull: false)
  final String phase;

  /// Whether the user has left AI chat enabled in settings.
  @JsonKey(name: r'aiChatEnabled', required: true, includeIfNull: false)
  final bool aiChatEnabled;

  /// Fine-grained AI chat context permissions from user settings.
  @JsonKey(name: r'aiChatContext', required: true, includeIfNull: false)
  final AiChatContextSettingsDto aiChatContext;

  /// Whether the configured chat model role exists server-side.
  @JsonKey(name: r'chatModelConfigured', required: true, includeIfNull: false)
  final bool chatModelConfigured;

  /// Whether an actual end-user chat interaction route is ready to be exposed.
  @JsonKey(name: r'interactiveChatReady', required: true, includeIfNull: false)
  final bool interactiveChatReady;

  /// Whether the LangGraph orchestration foundation is active.
  @JsonKey(name: r'langGraphReady', required: true, includeIfNull: false)
  final bool langGraphReady;

  /// Whether the current backend intends to stream responses.
  @JsonKey(name: r'streamingSupported', required: true, includeIfNull: false)
  final bool streamingSupported;

  /// Recommended streaming transport for the current chat contract.
  @JsonKey(name: r'streamingTransport', required: true, includeIfNull: false)
  final String streamingTransport;

  /// Whether the frontend should expect Markdown output and render it faithfully.
  @JsonKey(
    name: r'markdownRenderingRecommended',
    required: true,
    includeIfNull: false,
  )
  final bool markdownRenderingRecommended;

  /// Whether medicine-leaflet retrieval augmentation is currently enabled.
  @JsonKey(name: r'ragEnabled', required: true, includeIfNull: false)
  final bool ragEnabled;

  /// Tool-by-tool capability breakdown after combining system state and user permissions.
  @JsonKey(name: r'tools', required: true, includeIfNull: false)
  final List<AiChatToolCapabilityDto> tools;

  /// ISO-8601 timestamp of the latest related settings update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: true)
  final String? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatCapabilitiesDataDto &&
          other.phase == phase &&
          other.aiChatEnabled == aiChatEnabled &&
          other.aiChatContext == aiChatContext &&
          other.chatModelConfigured == chatModelConfigured &&
          other.interactiveChatReady == interactiveChatReady &&
          other.langGraphReady == langGraphReady &&
          other.streamingSupported == streamingSupported &&
          other.streamingTransport == streamingTransport &&
          other.markdownRenderingRecommended == markdownRenderingRecommended &&
          other.ragEnabled == ragEnabled &&
          other.tools == tools &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      phase.hashCode +
      aiChatEnabled.hashCode +
      aiChatContext.hashCode +
      chatModelConfigured.hashCode +
      interactiveChatReady.hashCode +
      langGraphReady.hashCode +
      streamingSupported.hashCode +
      streamingTransport.hashCode +
      markdownRenderingRecommended.hashCode +
      ragEnabled.hashCode +
      tools.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode);

  factory AiChatCapabilitiesDataDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatCapabilitiesDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatCapabilitiesDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
