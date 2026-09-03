//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_controller_confirm_proposal_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantControllerConfirmProposalV1Request {
  /// Returns a new [AssistantControllerConfirmProposalV1Request] instance.
  AssistantControllerConfirmProposalV1Request({
    required this.proposalIds,

    required this.decision,

    this.note,
  });

  /// Proposal ids awaiting confirmation.
  @JsonKey(name: r'proposalIds', required: true, includeIfNull: false)
  final List<String> proposalIds;

  @JsonKey(
    name: r'decision',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AssistantControllerConfirmProposalV1RequestDecisionEnum
        .unknownDefaultOpenApi,
  )
  final AssistantControllerConfirmProposalV1RequestDecisionEnum decision;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantControllerConfirmProposalV1Request &&
          other.proposalIds == proposalIds &&
          other.decision == decision &&
          other.note == note;

  @override
  int get hashCode => proposalIds.hashCode + decision.hashCode + note.hashCode;

  factory AssistantControllerConfirmProposalV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantControllerConfirmProposalV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantControllerConfirmProposalV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AssistantControllerConfirmProposalV1RequestDecisionEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantControllerConfirmProposalV1RequestDecisionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
