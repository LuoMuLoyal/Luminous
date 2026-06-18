//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/assistant_conversation_summary_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_conversation_list_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConversationListResponseDto {
  /// Returns a new [AssistantConversationListResponseDto] instance.
  AssistantConversationListResponseDto({
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

  /// Recent persisted conversations for the authenticated user, newest first.
  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final List<AssistantConversationSummaryDto> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConversationListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory AssistantConversationListResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConversationListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConversationListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
