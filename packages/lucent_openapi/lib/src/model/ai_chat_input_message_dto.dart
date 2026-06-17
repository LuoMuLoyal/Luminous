//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_input_message_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatInputMessageDto {
  /// Returns a new [AiChatInputMessageDto] instance.
  AiChatInputMessageDto({required this.role, required this.content});

  /// Client-visible conversation role. system is not accepted.
  @JsonKey(
    name: r'role',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AiChatInputMessageDtoRoleEnum.unknownDefaultOpenApi,
  )
  final AiChatInputMessageDtoRoleEnum role;

  /// Plain or Markdown-ready message content.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatInputMessageDto &&
          other.role == role &&
          other.content == content;

  @override
  int get hashCode => role.hashCode + content.hashCode;

  factory AiChatInputMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatInputMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatInputMessageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Client-visible conversation role. system is not accepted.
enum AiChatInputMessageDtoRoleEnum {
  /// Client-visible conversation role. system is not accepted.
  @JsonValue(r'user')
  user(r'user'),

  /// Client-visible conversation role. system is not accepted.
  @JsonValue(r'assistant')
  assistant(r'assistant'),

  /// Client-visible conversation role. system is not accepted.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AiChatInputMessageDtoRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
