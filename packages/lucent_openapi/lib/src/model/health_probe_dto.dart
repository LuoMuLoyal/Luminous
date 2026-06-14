//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/health_probe_type.dart';
import 'package:lucent_openapi/src/model/health_summary_dto.dart';
import 'package:lucent_openapi/src/model/health_component_dto.dart';
import 'package:lucent_openapi/src/model/health_app_info_dto.dart';
import 'package:lucent_openapi/src/model/health_overall_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_probe_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthProbeDto {
  /// Returns a new [HealthProbeDto] instance.
  HealthProbeDto({
    required this.probe,

    required this.status,

    required this.checkedAt,

    required this.app,

    required this.summary,

    required this.components,
  });

  @JsonKey(
    name: r'probe',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthProbeType.unknownDefaultOpenApi,
  )
  final HealthProbeType probe;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthOverallStatus.unknownDefaultOpenApi,
  )
  final HealthOverallStatus status;

  @JsonKey(name: r'checkedAt', required: true, includeIfNull: false)
  final String checkedAt;

  @JsonKey(name: r'app', required: true, includeIfNull: false)
  final HealthAppInfoDto app;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final HealthSummaryDto summary;

  @JsonKey(name: r'components', required: true, includeIfNull: false)
  final List<HealthComponentDto> components;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthProbeDto &&
          other.probe == probe &&
          other.status == status &&
          other.checkedAt == checkedAt &&
          other.app == app &&
          other.summary == summary &&
          other.components == components;

  @override
  int get hashCode =>
      probe.hashCode +
      status.hashCode +
      checkedAt.hashCode +
      app.hashCode +
      summary.hashCode +
      components.hashCode;

  factory HealthProbeDto.fromJson(Map<String, dynamic> json) =>
      _$HealthProbeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProbeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
