//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_outcome.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_health_event_check_in_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertHealthEventCheckInDto {
  /// Returns a new [UpsertHealthEventCheckInDto] instance.
  UpsertHealthEventCheckInDto({required this.outcome});

  /// User-confirmed outcome for the requested calendar date.
  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthEventOutcome.unknownDefaultOpenApi,
  )
  final HealthEventOutcome outcome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertHealthEventCheckInDto && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;

  factory UpsertHealthEventCheckInDto.fromJson(Map<String, dynamic> json) =>
      _$UpsertHealthEventCheckInDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertHealthEventCheckInDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
