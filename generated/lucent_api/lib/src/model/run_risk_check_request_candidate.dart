//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_risk_check_request_candidate.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunRiskCheckRequestCandidate {
  /// Returns a new [RunRiskCheckRequestCandidate] instance.
  RunRiskCheckRequestCandidate({required this.source_, required this.id});

  /// 候选药品所在的可信药品库来源
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        RunRiskCheckRequestCandidateSource_Enum.unknownDefaultOpenApi,
  )
  final RunRiskCheckRequestCandidateSource_Enum source_;

  /// 候选药品在可信药品库中的 id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunRiskCheckRequestCandidate &&
          other.source_ == source_ &&
          other.id == id;

  @override
  int get hashCode => source_.hashCode + id.hashCode;

  factory RunRiskCheckRequestCandidate.fromJson(Map<String, dynamic> json) =>
      _$RunRiskCheckRequestCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$RunRiskCheckRequestCandidateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// 候选药品所在的可信药品库来源
enum RunRiskCheckRequestCandidateSource_Enum {
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const RunRiskCheckRequestCandidateSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
