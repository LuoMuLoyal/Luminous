//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestions_response_secondary_evidence.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionsResponseSecondaryEvidence {
  /// Returns a new [TodaySuggestionsResponseSecondaryEvidence] instance.
  TodaySuggestionsResponseSecondaryEvidence({
    required this.kind,

    required this.label,

    required this.value,

    this.recordId,

    this.medicineId,
  });

  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final String kind;

  /// Human-readable label
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Human-readable value
  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final String value;

  /// Related record id for navigation
  @JsonKey(name: r'recordId', required: false, includeIfNull: false)
  final String? recordId;

  /// Related medicine id for navigation
  @JsonKey(name: r'medicineId', required: false, includeIfNull: false)
  final String? medicineId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionsResponseSecondaryEvidence &&
          other.kind == kind &&
          other.label == label &&
          other.value == value &&
          other.recordId == recordId &&
          other.medicineId == medicineId;

  @override
  int get hashCode =>
      kind.hashCode +
      label.hashCode +
      value.hashCode +
      recordId.hashCode +
      medicineId.hashCode;

  factory TodaySuggestionsResponseSecondaryEvidence.fromJson(
    Map<String, dynamic> json,
  ) => _$TodaySuggestionsResponseSecondaryEvidenceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodaySuggestionsResponseSecondaryEvidenceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
