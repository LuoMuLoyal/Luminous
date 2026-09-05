//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_check_in_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertCheckInRequest {
  /// Returns a new [UpsertCheckInRequest] instance.
  UpsertCheckInRequest({required this.outcome});

  /// User-confirmed outcome for the requested calendar date.
  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue: UpsertCheckInRequestOutcomeEnum.unknownDefaultOpenApi,
  )
  final UpsertCheckInRequestOutcomeEnum outcome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertCheckInRequest && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;

  factory UpsertCheckInRequest.fromJson(Map<String, dynamic> json) =>
      _$UpsertCheckInRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertCheckInRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User-confirmed outcome for the requested calendar date.
enum UpsertCheckInRequestOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpsertCheckInRequestOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
