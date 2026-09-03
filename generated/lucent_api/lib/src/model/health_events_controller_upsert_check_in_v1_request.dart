//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_events_controller_upsert_check_in_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventsControllerUpsertCheckInV1Request {
  /// Returns a new [HealthEventsControllerUpsertCheckInV1Request] instance.
  HealthEventsControllerUpsertCheckInV1Request({required this.outcome});

  /// User-confirmed outcome for the requested calendar date.
  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthEventsControllerUpsertCheckInV1RequestOutcomeEnum
        .unknownDefaultOpenApi,
  )
  final HealthEventsControllerUpsertCheckInV1RequestOutcomeEnum outcome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventsControllerUpsertCheckInV1Request &&
          other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;

  factory HealthEventsControllerUpsertCheckInV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthEventsControllerUpsertCheckInV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthEventsControllerUpsertCheckInV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User-confirmed outcome for the requested calendar date.
enum HealthEventsControllerUpsertCheckInV1RequestOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventsControllerUpsertCheckInV1RequestOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
