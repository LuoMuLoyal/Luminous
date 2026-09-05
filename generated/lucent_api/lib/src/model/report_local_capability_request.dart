//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_local_capability_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportLocalCapabilityRequest {
  /// Returns a new [ReportLocalCapabilityRequest] instance.
  ReportLocalCapabilityRequest({required this.state});

  /// Local scheduling capability state.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportLocalCapabilityRequestStateEnum.unknownDefaultOpenApi,
  )
  final ReportLocalCapabilityRequestStateEnum state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportLocalCapabilityRequest && other.state == state;

  @override
  int get hashCode => state.hashCode;

  factory ReportLocalCapabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportLocalCapabilityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReportLocalCapabilityRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Local scheduling capability state.
enum ReportLocalCapabilityRequestStateEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'disabled')
  disabled(r'disabled'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportLocalCapabilityRequestStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
