//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/risk_check_candidate_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_risk_check_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunRiskCheckDto {
  /// Returns a new [RunRiskCheckDto] instance.
  RunRiskCheckDto({required this.type, this.candidate});

  /// Type of risk check to run
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue: RunRiskCheckDtoTypeEnum.unknownDefaultOpenApi,
  )
  final RunRiskCheckDtoTypeEnum type;

  /// 加药前预检的可信药品库候选；仅 type=static 时允许；预检不落库
  @JsonKey(name: r'candidate', required: false, includeIfNull: false)
  final RiskCheckCandidateDto? candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunRiskCheckDto &&
          other.type == type &&
          other.candidate == candidate;

  @override
  int get hashCode => type.hashCode + candidate.hashCode;

  factory RunRiskCheckDto.fromJson(Map<String, dynamic> json) =>
      _$RunRiskCheckDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RunRiskCheckDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Type of risk check to run
enum RunRiskCheckDtoTypeEnum {
  /// Type of risk check to run
  @JsonValue(r'static')
  static_(r'static'),

  /// Type of risk check to run
  @JsonValue(r'llm')
  llm(r'llm'),

  /// Type of risk check to run
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const RunRiskCheckDtoTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
