//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_note_entry_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryNoteEntryDto {
  /// Returns a new [ClinicSummaryNoteEntryDto] instance.
  ClinicSummaryNoteEntryDto({
    required this.date,

    required this.kind,

    required this.text,
  });

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// Daily record kind (water/meal/vital/mood/symptom/activity/note/sleep).
  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final String kind;

  /// Original note text.
  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryNoteEntryDto &&
          other.date == date &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => date.hashCode + kind.hashCode + text.hashCode;

  factory ClinicSummaryNoteEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryNoteEntryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryNoteEntryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
