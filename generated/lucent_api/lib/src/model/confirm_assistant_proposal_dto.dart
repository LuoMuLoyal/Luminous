//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_assistant_proposal_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmAssistantProposalDto {
  /// Returns a new [ConfirmAssistantProposalDto] instance.
  ConfirmAssistantProposalDto({
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
    unknownEnumValue:
        ConfirmAssistantProposalDtoDecisionEnum.unknownDefaultOpenApi,
  )
  final ConfirmAssistantProposalDtoDecisionEnum decision;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmAssistantProposalDto &&
          other.proposalIds == proposalIds &&
          other.decision == decision &&
          other.note == note;

  @override
  int get hashCode => proposalIds.hashCode + decision.hashCode + note.hashCode;

  factory ConfirmAssistantProposalDto.fromJson(Map<String, dynamic> json) =>
      _$ConfirmAssistantProposalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmAssistantProposalDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ConfirmAssistantProposalDtoDecisionEnum {
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ConfirmAssistantProposalDtoDecisionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
