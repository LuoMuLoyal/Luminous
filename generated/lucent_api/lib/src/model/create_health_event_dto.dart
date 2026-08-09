//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_health_event_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateHealthEventDto {
  /// Returns a new [CreateHealthEventDto] instance.
  CreateHealthEventDto({
    required this.title,
    this.reasonRecordId,
    this.currentMedicineIds,
  });

  /// Short user-defined event title.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Optional daily-record id that prompted this event.
  @JsonKey(name: r'reasonRecordId', required: false, includeIfNull: false)
  final Object? reasonRecordId;

  /// Optional current-medicine ids to associate with this event.
  @JsonKey(name: r'currentMedicineIds', required: false, includeIfNull: false)
  final List<String>? currentMedicineIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateHealthEventDto &&
          other.title == title &&
          other.reasonRecordId == reasonRecordId &&
          other.currentMedicineIds == currentMedicineIds;

  @override
  int get hashCode =>
      title.hashCode +
      (reasonRecordId == null ? 0 : reasonRecordId.hashCode) +
      currentMedicineIds.hashCode;

  factory CreateHealthEventDto.fromJson(Map<String, dynamic> json) =>
      _$CreateHealthEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHealthEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
