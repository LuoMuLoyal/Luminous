//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/run_risk_check_request_candidate.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_risk_check_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunRiskCheckRequest {
  /// Returns a new [RunRiskCheckRequest] instance.
  RunRiskCheckRequest({required this.type, this.candidate});

  /// Type of risk check to run
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue: RunRiskCheckRequestTypeEnum.unknownDefaultOpenApi,
  )
  final RunRiskCheckRequestTypeEnum type;

  @JsonKey(name: r'candidate', required: false, includeIfNull: false)
  final RunRiskCheckRequestCandidate? candidate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunRiskCheckRequest &&
          other.type == type &&
          other.candidate == candidate;

  @override
  int get hashCode => type.hashCode + candidate.hashCode;

  factory RunRiskCheckRequest.fromJson(Map<String, dynamic> json) =>
      _$RunRiskCheckRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RunRiskCheckRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Type of risk check to run
enum RunRiskCheckRequestTypeEnum {
  @JsonValue(r'static')
  static_(r'static'),
  @JsonValue(r'llm')
  llm(r'llm'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const RunRiskCheckRequestTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
