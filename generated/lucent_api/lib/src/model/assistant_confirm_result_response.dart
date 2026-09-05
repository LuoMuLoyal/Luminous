//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_confirm_result_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConfirmResultResponse {
  /// Returns a new [AssistantConfirmResultResponse] instance.
  AssistantConfirmResultResponse({
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
        AssistantConfirmResultResponseDecisionEnum.unknownDefaultOpenApi,
  )
  final AssistantConfirmResultResponseDecisionEnum decision;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AssistantConfirmResultResponseStatusEnum.unknownDefaultOpenApi,
  )
  final AssistantConfirmResultResponseStatusEnum status;

  /// Final assistant content after the decision is applied.
  @JsonKey(name: r'finalContent', required: true, includeIfNull: true)
  final String? finalContent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConfirmResultResponse &&
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

  factory AssistantConfirmResultResponse.fromJson(Map<String, dynamic> json) =>
      _$AssistantConfirmResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantConfirmResultResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AssistantConfirmResultResponseDecisionEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConfirmResultResponseDecisionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AssistantConfirmResultResponseStatusEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConfirmResultResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
