//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_confirm_result_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConfirmResultDto {
  /// Returns a new [AssistantConfirmResultDto] instance.
  AssistantConfirmResultDto({
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
        AssistantConfirmResultDtoDecisionEnum.unknownDefaultOpenApi,
  )
  final AssistantConfirmResultDtoDecisionEnum decision;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AssistantConfirmResultDtoStatusEnum.unknownDefaultOpenApi,
  )
  final AssistantConfirmResultDtoStatusEnum status;

  /// Final assistant content after the decision is applied.
  @JsonKey(name: r'finalContent', required: true, includeIfNull: true)
  final String? finalContent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConfirmResultDto &&
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

  factory AssistantConfirmResultDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantConfirmResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantConfirmResultDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AssistantConfirmResultDtoDecisionEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConfirmResultDtoDecisionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AssistantConfirmResultDtoStatusEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConfirmResultDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
