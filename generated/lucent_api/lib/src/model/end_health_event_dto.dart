//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_outcome.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'end_health_event_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EndHealthEventDto {
  /// Returns a new [EndHealthEventDto] instance.
  EndHealthEventDto({required this.outcome});

  /// User-confirmed outcome when ending the event.
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
      other is EndHealthEventDto && other.outcome == outcome;

  @override
  int get hashCode => outcome.hashCode;

  factory EndHealthEventDto.fromJson(Map<String, dynamic> json) =>
      _$EndHealthEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EndHealthEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
