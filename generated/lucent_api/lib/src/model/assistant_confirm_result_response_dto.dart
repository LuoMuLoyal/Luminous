//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_confirm_result_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConfirmResultResponseDto {
  /// Returns a new [AssistantConfirmResultResponseDto] instance.
  AssistantConfirmResultResponseDto({
    required this.conversationId,

    required this.decision,

    required this.status,

    required this.finalContent,
  });

  /// Conversation (LangGraph thread) id the proposals belong to.
  @JsonKey(name: r'conversationId', required: true, includeIfNull: false)
  final String conversationId;

  @JsonKey(
    name: r'decision',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AssistantConfirmResultResponseDtoDecisionEnum.unknownDefaultOpenApi,
  )
  final AssistantConfirmResultResponseDtoDecisionEnum decision;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AssistantConfirmResultResponseDtoStatusEnum.unknownDefaultOpenApi,
  )
  final AssistantConfirmResultResponseDtoStatusEnum status;

  /// Final assistant content after the decision is applied.
  @JsonKey(name: r'finalContent', required: true, includeIfNull: true)
  final String? finalContent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConfirmResultResponseDto &&
          other.conversationId == conversationId &&
          other.decision == decision &&
          other.status == status &&
          other.finalContent == finalContent;

  @override
  int get hashCode =>
      conversationId.hashCode +
      decision.hashCode +
      status.hashCode +
      (finalContent == null ? 0 : finalContent.hashCode);

  factory AssistantConfirmResultResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConfirmResultResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConfirmResultResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AssistantConfirmResultResponseDtoDecisionEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConfirmResultResponseDtoDecisionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AssistantConfirmResultResponseDtoStatusEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConfirmResultResponseDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
