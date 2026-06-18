//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/assistant_conversation_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_conversation_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConversationResponseDto {
  /// Returns a new [AssistantConversationResponseDto] instance.
  AssistantConversationResponseDto({
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
  final AssistantConversationDataDto? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConversationResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + (data == null ? 0 : data.hashCode);

  factory AssistantConversationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConversationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConversationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
