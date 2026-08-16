//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'risk_check_candidate_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RiskCheckCandidateDto {
  /// Returns a new [RiskCheckCandidateDto] instance.
  RiskCheckCandidateDto({required this.source_, required this.id});

  /// 候选药品所在的可信药品库来源
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue: RiskCheckCandidateDtoSource_Enum.unknownDefaultOpenApi,
  )
  final RiskCheckCandidateDtoSource_Enum source_;

  /// 候选药品在可信药品库中的 id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskCheckCandidateDto &&
          other.source_ == source_ &&
          other.id == id;

  @override
  int get hashCode => source_.hashCode + id.hashCode;

  factory RiskCheckCandidateDto.fromJson(Map<String, dynamic> json) =>
      _$RiskCheckCandidateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RiskCheckCandidateDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// 候选药品所在的可信药品库来源
enum RiskCheckCandidateDtoSource_Enum {
  /// 候选药品所在的可信药品库来源
  @JsonValue(r'cn')
  cn(r'cn'),

  /// 候选药品所在的可信药品库来源
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),

  /// 候选药品所在的可信药品库来源
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const RiskCheckCandidateDtoSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
