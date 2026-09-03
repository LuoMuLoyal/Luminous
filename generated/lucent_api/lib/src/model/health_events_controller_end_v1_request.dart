//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_events_controller_end_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventsControllerEndV1Request {
  /// Returns a new [HealthEventsControllerEndV1Request] instance.
  HealthEventsControllerEndV1Request({required this.outcome});

  /// User-confirmed outcome when ending the event.
  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthEventsControllerEndV1RequestOutcomeEnum.unknownDefaultOpenApi,
  )
  final HealthEventsControllerEndV1RequestOutcomeEnum outcome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventsControllerEndV1Request && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;

  factory HealthEventsControllerEndV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthEventsControllerEndV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthEventsControllerEndV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User-confirmed outcome when ending the event.
enum HealthEventsControllerEndV1RequestOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventsControllerEndV1RequestOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
