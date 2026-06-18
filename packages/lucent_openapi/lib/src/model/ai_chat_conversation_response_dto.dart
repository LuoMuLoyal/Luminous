//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/ai_chat_conversation_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_conversation_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatConversationResponseDto {
  /// Returns a new [AiChatConversationResponseDto] instance.
  AiChatConversationResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  /// Persisted conversation payload, or null when none exists.
  @JsonKey(name: r'data', required: true, includeIfNull: true)
  final AiChatConversationDataDto? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatConversationResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + (data == null ? 0 : data.hashCode);

  factory AiChatConversationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatConversationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatConversationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
