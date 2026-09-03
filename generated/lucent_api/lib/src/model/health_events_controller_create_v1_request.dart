//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_events_controller_create_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventsControllerCreateV1Request {
  /// Returns a new [HealthEventsControllerCreateV1Request] instance.
  HealthEventsControllerCreateV1Request({
    this.kind,

    required this.title,

    this.reasonRecordId,

    this.currentMedicineIds,
  });

  /// Persisted semantic kind used for check-in routing.
  @JsonKey(
    name: r'kind',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        HealthEventsControllerCreateV1RequestKindEnum.unknownDefaultOpenApi,
  )
  final HealthEventsControllerCreateV1RequestKindEnum? kind;

  /// Short user-defined event title.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Optional daily-record id that prompted this event.
  @JsonKey(name: r'reasonRecordId', required: false, includeIfNull: false)
  final String? reasonRecordId;

  /// Optional current-medicine ids to associate with this event.
  @JsonKey(name: r'currentMedicineIds', required: false, includeIfNull: false)
  final List<String>? currentMedicineIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventsControllerCreateV1Request &&
          other.kind == kind &&
          other.title == title &&
          other.reasonRecordId == reasonRecordId &&
          other.currentMedicineIds == currentMedicineIds;

  @override
  int get hashCode =>
      kind.hashCode +
      title.hashCode +
      (reasonRecordId == null ? 0 : reasonRecordId.hashCode) +
      currentMedicineIds.hashCode;

  factory HealthEventsControllerCreateV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthEventsControllerCreateV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthEventsControllerCreateV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted semantic kind used for check-in routing.
enum HealthEventsControllerCreateV1RequestKindEnum {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventsControllerCreateV1RequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
