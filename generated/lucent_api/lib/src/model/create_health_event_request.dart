//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_health_event_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateHealthEventRequest {
  /// Returns a new [CreateHealthEventRequest] instance.
  CreateHealthEventRequest({
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
    unknownEnumValue: CreateHealthEventRequestKindEnum.unknownDefaultOpenApi,
  )
  final CreateHealthEventRequestKindEnum? kind;

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
      other is CreateHealthEventRequest &&
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

  factory CreateHealthEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateHealthEventRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHealthEventRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted semantic kind used for check-in routing.
enum CreateHealthEventRequestKindEnum {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateHealthEventRequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
